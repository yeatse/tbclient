.pragma library

Qt.include("Utils.js");

var BaiduParser = {
    loadLikeForum:
    function(model, list){
        model.clear();
        list.forEach(function(value){
                         var isSign = value.is_sign === "1";
                         var prop = {
                             forum_id: value.forum_id,
                             is_sign: isSign,
                             forum_name: value.forum_name,
                             level_id: Number(value.level_id)
                         };
                         model.append(prop);
                     });
    },

    loadForumPage:
    function(option, list){
        var model = option.model;
        if (option.renew)
            model.clear();
        list.forEach(function(value){
                         var picUrl = "";
                         if (tbsettings.showImage
                                 && tbsettings.showAbstract
                                 && Array.isArray(value.media)){
                             value.media.some(function(media){
                                                  if (media.type === "3"){
                                                      picUrl = getThumbnail(media.big_pic);
                                                      return true;
                                                  }
                                              });
                         }
                         var abst = "";
                         if (tbsettings.showAbstract
                                 && Array.isArray(value.abstract)){
                             value.abstract.some(function(abstr){
                                                     if (abstr.type === "0"){
                                                         abst = abstr.text;
                                                         return true;
                                                     }
                                                 })
                         }
                         var numShow = value.reply_num;
                         if (value.view_num) numShow += "/"+value.view_num;
                         if (value.last_replyer && value.last_replyer.name_show)
                             numShow += "  "+value.last_replyer.name_show;
                         var prop = {
                             id: value.id,
                             title: value.title,
                             last_time: Number(value.last_time_int+"000"),
                             is_top: value.is_top === "1",
                             is_good: value.is_good === "1",
                             author: value.author.name_show,
                             picUrl: picUrl,
                             abstract: abst,
                             num_show: numShow
                         };
                         model.append(prop);
                     });
    },

    loadForumPicture:
    function(option, list){
        var model1 = option.model1, model2 = option.model2;
        if (option.renew){
            model1.clear(); model2.clear();
            model1.cursor = 0; model2.cursor = 0;
        }
        var cursor1 = model1.cursor, cursor2 = model2.cursor;
        list.forEach(function(value){
                         var h = value.photo.height, w = value.photo.width;
                         var height = Math.round(h/w*200);
                         var cover = "";
                         if (w > 180)
                             cover = "http://imgsrc.baidu.com/forum/abpic/item/"+value.photo.id+".jpg";
                         else
                             cover = "http://imgsrc.baidu.com/forum/pic/item/"+value.photo.id+".jpg";
                         var prop = {
                             title: value.title,
                             tid: value.tid,
                             amount: value.amount,
                             cover: cover,
                             pwidth: w,
                             pheight: h
                         }
                         if (cursor1 <= cursor2){
                             model1.append(prop);
                             cursor1 += height;
                         } else {
                             model2.append(prop);
                             cursor2 += height;
                         }
                     });
        model1.cursor = cursor1;
        model2.cursor = cursor2;
    },

    __parseThreadContent:
    function(content){
        /*
        input: content list, js array
        output: [ item1, item2, ... ]
        each item should be a jsobject like this:
        {
            type: [string, "Text", "Image" or "Audio"]
            text: [string, readable text for Text, readable source for Image, md5 for Audio],
            format: [variant, 1 for RichText and 0 for PlainText, duration for Audio, source for Image],
            bwidth: image width, <= 200
            bheight: image height, scaled by width and <= 200
        }
        type: string
        0 for text;
        1 for link;
        2 for emoticon;
        3 for image;
        4 for at;
        5 for video;
        9 for phone number;
        10 for audio;
        */
        var result = [];
        var maxRichLength = 500;
        var push = function(type, text, format, bwidth, bheight){
            var prop = {
                type: type,
                text: text,
                format: format,
                bwidth: bwidth,
                bheight: bheight
            };
            result.push(prop);
        };
        var pushRich = function(lastObj, richText){
            if (lastObj && lastObj.type === "Text"
                    && (lastObj.format === 1||lastObj.text.length + richText.length < maxRichLength)){
                lastObj.text += richText;
                if (lastObj.format === 0){
                    lastObj.format = 1;
                    lastObj.text = lastObj.text.replace(/\n/g, "<br/>");
                }
            } else {
                push("Text", richText, 1, 0, 0);
            }
        };
        var parse = function(c){
            var l = result[result.length-1];
            switch (c.type){
            case "0":
                c.text = c.text||"";
                if (l && l.type === "Text"){
                    if (l.format === 0){
                        l.text += c.text;
                        return;
                    }
                    if (l.text.length < maxRichLength && c.text.length < maxRichLength){
                        if (l.text.length + c.text.length < maxRichLength){
                            l.text += c.text.replace(/\n/g, "<br/>");
                            return;
                        }
                        var sp = c.text.split("\n");
                        if (l.text.length + sp[0].length < maxRichLength){
                            l.text += sp.shift();
                            if (sp.length > 0)
                                push("Text", sp.join("\n"), 0, 0, 0);
                            return;
                        }
                    }
                };
                push("Text", c.text, 0, 0, 0);
                return;
            case "1":
                pushRich(l, "<a href='link:%1'>%2</a>".arg(c.link).arg(c.text), 300);
                return;
            case "2":
                pushRich(l, getEmoticon(c.text, c.c), 300);
                return;
            case "3":
                if (tbsettings.showImage){
                    var bsize = c.bsize.split(","), w = Number(bsize[0]), h = Number(bsize[1]);
                    var ww = Math.min(200, w), hh = Math.min(h * ww/w, 200);
                    push("Image", c.src, c.src, ww, hh);
                } else {
                    push("Image", "", c.src, 200, 200);
                }
                return;
            case "4":
                pushRich(l, "<a href='at:%1'>%2</a>".arg(c.uid).arg(c.text), 300);
                return;
            case "5":
                pushRich(l, "<br/><a href='video:%1'>%2</a><br/>".arg(c.text).arg(qsTr("Click to watch video")), 300);
                return;
            case "9":
                if (l && l.type === "Text")
                    l.text += c.text;
                else
                    push("Text", c.text, 0, 0, 0);
                return;
            case "10":
                push("Audio", c.voice_md5, Number(c.during_time), 0, 0);
                return;
            }
        };
        content.forEach(parse);
        return result;
    },

    loadThreadPage:
    function(option, list){
        var self = this;
        var modelAffected = 0;
        var model = option.model;
        if (option.renew)
            model.clear();
        list.forEach(function(value){
                         if (option.dirty){
                             if (option.insert){
                                 for (var i=0;i<model.count;i++){
                                     if (value.id === model.get(i).id)
                                         return;
                                 }
                             } else {
                                 for (var i=model.count-1;i>=0;i--){
                                     if (value.id === model.get(i).id)
                                         return;
                                 }
                             }
                         }
                         var portrait = tbsettings.showImage
                                 ? getPortrait(value.author.portrait)
                                 : Qt.resolvedUrl("../gfx/photo.png");
                         var prop = {
                             id: value.id,
                             floor: value.floor,
                             time: Qt.formatDateTime(new Date(Number(value.time+"000")),"yyyy-MM-dd hh:mm:ss"),
                             authorName: value.author.name_show,
                             authorPortrait: portrait,
                             authorId: value.author.id,
                             authorLevel: value.author.level_id,
                             sub_post_number: value.sub_post_number,
                             content: self.__parseThreadContent(value.content)
                         };
                         if (option.insert){
                             model.insert(modelAffected, prop);
                         } else {
                             model.append(prop);
                         }
                         modelAffected ++;
                     });
        return modelAffected > 0;
    },

    loadComlist:
    function(option, list){
        var model = option.model;
        if (option.renew) model.clear();
        list.forEach(function(value){
                         var portrait = tbsettings.showImage
                                 ? getPortrait(value.portrait)
                                 : Qt.resolvedUrl("../gfx/photo.png");
                         var text = "";
                         value.abstract.forEach(function(abs){
                                                    if (abs.text)
                                                        text += abs.text;
                                                });
                         var prop = {
                             user_id: value.user_id,
                             name_show: value.name_show,
                             portrait: portrait,
                             time: Number(value.time+"000"),
                             unread_count: Number(value.unread_count),
                             text: text
                         };
                         model.append(prop);
                     });
    },

    loadReplyme:
    function(option, list){
        var model = option.model;
        if (option.renew) model.clear();
        list.forEach(function(value){
                         var portrait = tbsettings.showImage
                                 ? getPortrait(value.replyer.portrait)
                                 : Qt.resolvedUrl("../gfx/photo.png");
                         var prop = {
                             // subfloor
                             is_floor: value.is_floor === "1",
                             // 1 for my post, 2 for my main thread
                             quoteMe: value.type === "1",
                             replyer: value.replyer.name_show,
                             portrait: portrait,
                             title: value.title,
                             content: value.content.replace(/\n/g, " "),
                             quote_content: value.quote_content,
                             thread_id: value.thread_id,
                             post_id: value.post_id,
                             quote_pid: value.quote_pid,
                             time: Number(value.time+"000"),
                             fname: value.fname
                         }
                         model.append(prop);
                     });
    },

    loadAtme:
    function(option, list){
        var model = option.model;
        if (option.renew) model.clear();
        list.forEach(function(value){
                         var portrait = tbsettings.showImage
                                 ? getPortrait(value.replyer.portrait)
                                 : Qt.resolvedUrl("../gfx/photo.png");
                         var prop = {
                             is_floor: value.is_floor === "1",
                             replyer: value.replyer.name_show,
                             portrait: portrait,
                             content: value.content,
                             thread_id: value.thread_id,
                             post_id: value.post_id,
                             time: Number(value.time+"000"),
                             fname: value.fname
                         }
                         model.append(prop);
                     });
    },

    __parseFloorContent:
    function(content){
        var result = "", textFormat = 0;
        var parse = function(c){
            switch(c.type){
            case "0":
                result += c.text||"";
                break;
            case "1":
                result += "<a href='link:%1'>%2</a>".arg(c.link).arg(c.text);
                textFormat = 1;
                break;
            case "2":
                result += getEmoticon(c.text, c.c);
                textFormat = 1;
                break;
            case "4":
                result += "<a href='at:%1'>%2</a>".arg(c.uid).arg(c.text);
                textFormat = 1;
                break;
            case "9":
                result += c.text;
                break;
            default:
                break;
            }
        };
        content.forEach(parse);
        return [result, textFormat];
    },

    loadFloorPage:
    function(option, list){
        var self = this;
        var model = option.model;
        if (option.renew) model.clear();
        list.forEach(function(value){
                         var content = self.__parseFloorContent(value.content);
                         var time = Qt.formatDateTime(new Date(Number(value.time+"000")));
                         var prop = {
                             id: value.id,
                             author: value.author.name_show,
                             content: content[0],
                             format: content[1],
                             time: time
                         }
                         model.append(prop);
                     });
    }
};
