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
                         if (value.is_top !== "1"
                                 && tbsettings.showImage
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
                         if (value.is_top !== "1"
                                 && tbsettings.showAbstract
                                 && Array.isArray(value.abstract)){
                             value.abstract.some(function(abstr){
                                                     if (abstr.type === "0"){
                                                         abst = abstr.text;
                                                         return true;
                                                     }
                                                 })
                         }

                         var reply_show = "";
                         if (value.last_replyer && value.last_replyer.name_show)
                             reply_show = value.last_replyer.name_show + "  ";
                         reply_show += utility.easyDate(new Date(Number(value.last_time_int+"000")));
                         var prop = {
                             id: value.id,
                             title: value.title,
                             is_top: value.is_top === "1",
                             is_good: value.is_good === "1",
                             author: value.author.name_show,
                             picUrl: picUrl,
                             abstract: abst,
                             reply_show: reply_show,
                             reply_num: value.reply_num
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

    __parseRawText:
    function(content){
        var result = "";
        content.forEach(function(value){
                            switch (value.type){
                            case "0": result += value.text||""; break;
                            case "1": result += value.link; break;
                            case "2": result += value.c||value.text; break;
                            case "3": result += value.big_cdn_src||value.src; break;
                            case "4":
                            case "5":
                            case "9": result += value.text; break;
                            }
                        });
        return result;
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
                pushRich(l, "<a href='link:"+c.link+"'>"+c.text+"</a>");
                return;
            case "2":
                pushRich(l, getEmoticon(c.text, c.c));
                return;
            case "3":
                if (tbsettings.showImage){
                    var bsize = c.bsize.split(","), w = Number(bsize[0]), h = Number(bsize[1]);
                    var ww = Math.min(200, w), hh = Math.min(h * ww/w, 200);
                    push("Image", getThumbnail(c.cdn_src||c.src), getBigImage(c.big_cdn_src||c.src), ww, hh);
                } else {
                    push("Image", "", getBigImage(c.big_cdn_src||c.src), 200, 200);
                }
                return;
            case "4":
                pushRich(l, "<a href='at:"+c.uid+"'>"+c.text+"</a>");
                return;
            case "5":
                pushRich(l, "<br/><a href='video:"+c.text+"'>%1</a><br/>".arg(qsTr("Click to watch video")));
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
                             content: self.__parseThreadContent(value.content),
                             content_raw: self.__parseRawText(value.content)
                         };
                         if (option.insert){
                             if (option.arround)
                                 model.insert(0, prop);
                             else
                                 model.insert(modelAffected, prop);
                         } else {
                             model.append(prop);
                         }
                         modelAffected ++;
                     });
        return modelAffected;
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
                             time: utility.easyDate(new Date(Number(value.time+"000"))),
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
                             time: utility.easyDate(new Date(Number(value.time+"000"))),
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
                             time: utility.easyDate(new Date(Number(value.time+"000"))),
                             fname: value.fname,
                             title: value.title
                         }
                         model.append(prop);
                     });
    },

    __parseFloorContent:
    function(content){
        var result = "", textFormat = 0;
        var enrich = function(){
            if (textFormat == 0){
                result = result.replace(/\n/g,"<br/>").replace(/</g,"&lt;");
                textFormat = 1;
            }
        }
        var parse = function(c){
            switch(c.type){
            case "0":
                if (textFormat == 0){
                    result += (c.text||"")
                } else {
                    result += (c.text||"").replace(/\n/g,"<br/>").replace(/</g,"&lt;");
                }
                break;
            case "1":
                enrich();
                result += "<a href='link:"+c.link+"'>"+c.text+"</a>";
                break;
            case "2":
                enrich();
                result += getEmoticon(c.text, c.c);
                break;
            case "4":
                enrich();
                result += "<a href='at:"+c.uid+"'>"+c.text+"</a>";
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
                         var time = Qt.formatDateTime(new Date(Number(value.time+"000")), "yyyy-MM-dd hh:mm:ss");
                         var voiceMd5 = "", voiceDuration = 0;
                         if (value.voice_info && value.voice_info.length){
                             voiceMd5 = value.voice_info[0].voice_md5;
                             voiceDuration = Number(value.voice_info[0].during_time);
                         }
                         var prop = {
                             id: value.id,
                             author: value.author.name_show,
                             authorId: value.author.id,
                             content: content[0],
                             format: content[1],
                             time: time,
                             voiceMd5: voiceMd5,
                             voiceDuration: voiceDuration
                         }
                         model.append(prop);
                     });
    },

    loadForumSuggest:
    function(option, list){
        var model = option.model;
        model.clear();
        list.forEach(function(fname){
                         model.append({name: fname});
                     });
    },

    loadSearchPost:
    function(option, list){
        var model = option.model;
        if (option.renew) model.clear();
        list.forEach(function(value){
                         var prop = {
                             content: value.content.replace(/<\/?em>/g, ""),
                             fname: value.fname,
                             is_floor: value.is_floor === "1",
                             pid: value.pid,
                             tid: value.tid,
                             title: value.title.replace(/<\/?em>/g, ""),
                             time: Qt.formatDate(new Date(Number(value.time+"000")), "yyyy-MM-dd")
                         }
                         model.append(prop);
                     });
    },

    loadPicturePage:
    function (option, list){
        var model = option.model;
        var self = this;
        if (option.renew) model.clear();
        list.forEach(function(value){
                         var o = value.img.original;
                         var prop = {
                             post_id: value.post_id,
                             pic_id: o.id,
                             pic_ratio: o.width/o.height,
                             descr: self.__parseRawText(value.descr),
                             user_id: value.user_id,
                             user_name: value.user_name,
                             comment_amount: value.comment_amount,
                             idx: value.index,
                             url: getBigImage(o.url)
                         };
                         model.append(prop);
                     });
    },

    loadPicComment:
    function (option, list){
        var model = option.model;
        var self = this;
        if (option.renew) model.clear();
        list.forEach(function(value){
                         var content = self.__parseFloorContent(value.content);
                         var prop = {
                             author: value.author.name_show,
                             content: content[0],
                             format: content[1],
                             time: utility.easyDate(new Date(Number(value.time+"000"))),
                             voiceMd5: "",
                             voiceDuration: 0
                         }
                         model.append(prop);
                     });
    },

    loadForumFeed:
    function (option, list){
        var model = option.model;
        if (option.renew) model.clear();
        list.forEach(function(value){
                         if (value.thread_type !== "8"&&value.thread_type !== "11")
                             return;
                         var picUrl = "";
                         if (tbsettings.showImage && Array.isArray(value.media)){
                             value.media.some(function(media){
                                                  if (media.type === "3"){
                                                      picUrl = getThumbnail(media.big_pic);
                                                      return true;
                                                  }
                                              });
                         }
                         var abst = "";
                         if (Array.isArray(value.abstract)){
                             value.abstract.some(function(abstr){
                                                     if (abstr.type === "0"){
                                                         abst = abstr.text;
                                                         return true;
                                                     }
                                                 })
                         }
                         var prop = {
                             forum_id: value.forum_id,
                             thread_id: value.thread_id,
                             forum_name: value.forum_name,
                             user_name: value.user_name,
                             post_num: value.post_num,
                             is_good: value.is_good === "1",
                             is_top: value.is_top === "1",
                             title: value.title,
                             create_time: utility.easyDate(new Date(Number(value.create_time+"000"))),
                             picUrl: picUrl,
                             abstract: abst
                         }
                         model.append(prop);
                     });
    },

    loadUserLikedForum:
    function(model, list){
        model.clear();
        list.forEach(function(value){
                         value.avatar = utility.percentDecode(value.avatar);
                         model.append(value)
                     });
    },

    loadMyPost:
    function(option, list){
        var model = option.model;
        if (option.renew) model.clear();
        list.forEach(function(value){
                         var prop = {
                             fname: value.fname,
                             is_floor: value.is_floor === "1",
                             pid: value.pid,
                             reply_num: value.reply_num,
                             reply_time: value.reply_time,
                             tid: value.tid,
                             time_shaft: value.time_shaft,
                             title: value.title,
                             isReply: value.type === "1"
                         };
                         model.append(prop);
                     });
    },

    loadUserList:
    function(option, list){
        var model = option.model;
        if (option.renew) model.clear();
        list.forEach(function(value){
                         value.portrait = tbsettings.showImage
                                 ? getPortrait(value.portrait)
                                 : Qt.resolvedUrl("../gfx/photo.png");
                         model.append(value);
                     });
    },

    loadBookmark:
    function(option, list){
        var model = option.model;
        if (option.renew) model.clear();
        list.forEach(function(value){
                         var prop = {
                             author: value.author.name_show,
                             isNew: value.count !== "0",
                             mark_pid: value.mark_pid,
                             isReverse: value.mark_status === "2",
                             isLz: value.mark_status === "1",
                             reply_num: value.reply_num,
                             isVisible: value.status === "0",
                             thread_id: value.thread_id,
                             title: value.title,
                             isReply: value.type === "2"
                         }
                         model.append(prop);
                     });
    },

    loadChatList:
    function(option, list){
        var self = this;
        var model = option.model;
        if (option.renew) model.clear();
        list.forEach(function(value, index){
                         var prop = {
                             content: self.__parseRawText(value.content),
                             isMe: value.from === "1",
                             msg_id: value.msg_id,
                             time: Qt.formatDate(new Date(Number(value.time+"000")), "yyyy-MM-dd")
                         }
                         if (option.history){
                             model.insert(index, prop);
                         } else {
                             model.append(prop);
                         }
                     });
    },

    loadForumForSign:
    function(option, list){
        var model = option.model;
        model.clear();
        var signedCount = 0;
        list.forEach(function(value){
                         var prop = {
                             avatar: value.avatar,
                             cont_sign_num: value.cont_sign_num,
                             forum_id: value.forum_id,
                             forum_name: value.forum_name,
                             hasSigned: value.is_sign_in === "1",
                             need_exp: value.need_exp,
                             user_exp: value.user_exp,
                             user_level: value.user_level
                         }
                         if (prop.hasSigned) signedCount ++;
                         model.append(prop);
                     });
        return signedCount;
    },

    loadForumSquareList:
    function(option, list){
        var model = option.model;
        if (option.renew) model.clear();
        var shorten = function(num){
            if (num.length >= 5){
                return num.substring(0, num.length-4)+"w";
            } else {
                return num;
            }
        }
        list.forEach(function(value){
                         var prop = {
                             avatar: utility.percentDecode(value.avatar),
                             forum_id: value.forum_id,
                             forum_name: value.forum_name,
                             member_count: shorten(value.member_count),
                             thread_count: shorten(value.thread_count),
                             slogan: value.slogan
                         }
                         model.append(prop);
                     })
    },

    loadForumDir:
    function(model, list){
        model.clear();
        list.forEach(function(value){
                         var subtitle = [];
                         var cl = value.child_menu_list;
                         if (Array.isArray(cl)){
                             cl.forEach(function(c){
                                            subtitle.push(c.menu_name);
                                        });
                         }
                         var prop = {
                             default_logo_url: value.default_logo_url,
                             menu_id: value.menu_id,
                             menu_name: value.menu_name,
                             menu_type: value.menu_type,
                             subtitle: subtitle.join(" ")
                         }
                         model.append(prop);
                     });
    },

    loadForumDir2:
    function(model, dir){
        model.clear();
        if (!dir || !Array.isArray(dir.child_menu_list))
            return;
        dir.child_menu_list.forEach(function(value){
                                        var prop = {
                                            menu_id: value.menu_id,
                                            menu_name: value.menu_name,
                                            menu_type: value.menu_type,
                                            modelData: value.menu_name
                                        }
                                        model.append(prop);
                                    });
        var prop = {
            menu_id: dir.menu_id,
            menu_name: dir.menu_name,
            menu_type: dir.menu_type,
            modelData: "全部"
        }
        model.insert(0, prop);
    },

    loadForumRank:
    function(option, obj){
        var model1 = option.leftModel, model2 = option.rightModel;
        if (option.renew){ model1.clear(); model2.clear(); }
        if (!obj.recommend_list_left)
            return [false, 0];

        var list1 = obj.recommend_list_left.forum_list;
        var list2 = obj.recommend_list_right.forum_list;
        var hasMore = obj.recommend_list_left.has_more === "1"
                && obj.recommend_list_right.has_more === "1";
        var shorten = function(num){
            if (num.length >= 5){
                return num.substring(0, num.length-4)+"w";
            } else {
                return num;
            }
        }
        var parse = function(list, model){
            list.forEach(function(value){
                             var prop = {
                                 avatar: utility.percentDecode(value.avatar),
                                 forum_id: value.forum_id,
                                 forum_name: value.forum_name,
                                 member_count: shorten(value.member_count),
                                 thread_count: shorten(value.thread_count),
                                 slogan: value.slogan
                             }
                             model.append(prop);
                         });
        }
        parse(list1, model1);
        parse(list2, model2);
        return [hasMore, Math.min(list1.length, list2.length)];
    },

    loadGoodList:
    function(list){
        var result = [];
        result.push({modelData: "全部", id: ""});
        list.forEach(function(value){
                         var prop = {
                             modelData: value.name,
                             id: value.id
                         };
                         result.push(prop);
                     });
        return result;
    }
};
