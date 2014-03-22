var imageCursor = 0;    // index of current image
var imageInfoList = []; // id, width, height

var voiceUploaded = false;
var voiceMd5 = "";

var chunkFileOffset = 0;

function post(vcode, vcodeMd5){
    if (isReply){
        if (contentArea.text == ""&&attachedArea.imageList.length == 0 && attachedArea.audioFile == ""){
            signalCenter.showMessage(qsTr("Content required"));
            return;
        }
    } else {
        if (titlefield.text.length == 0||!titlefield.acceptableInput){
            signalCenter.showMessage(qsTr("Illegal title"));
            return;
        }
    }

    if (imageCursor < attachedArea.imageList.length){
        var fn = attachedArea.imageList[imageCursor];
        if (utility.fileSize(fn) >= 0x160000){
            fn = utility.resizeImage(fn);
        }
        if (fn !== ""){
            Script.uploadImage(page, fn);
        } else {
            imageCursor ++;
            postTimer.start();
        }
        return;
    }
    if (!voiceUploaded && attachedArea.audioFile != ""){
        Script.chunkUpload(page, "Voice", attachedArea.audioFile, chunkFileOffset);
        return;
    }
    var content = contentArea.text;
    imageInfoList.forEach(function(info){
                              content += "#(pic,"+info.id+","+info.width+","+info.height+")";
                          });
    var opt, s, f = function(err, obj){
        loading = false;
        signalCenter.showMessage(err);
        if (obj && obj.info && obj.info.need_vcode === "1"){
            signalCenter.needVCode(page, obj.info.vcode_md5, obj.info.vcode_pic_url, obj.info.vcode_type === "4");
        }
    };
    if (isReply){
        opt = {
            tid: caller.thread.id,
            fid: caller.forum.id,
            content: content,
            kw: caller.forum.name
        }
        if (voiceMd5){
            opt.during_time = Math.floor(attachedArea.audioDuration/1000);
            opt.voice_md5 = voiceMd5;
        }
        if (vcode){
            opt.vcode = vcode;
            opt.vcode_md5 = vcodeMd5;
        }
        if (tbsettings.signature !== "")
            opt.content += "\n"+tbsettings.signature;
        loading = true;
        s = function(){
                    tbsettings.draftBox = "";
                    loading = false;
                    signalCenter.showMessage(qsTr("Success"));
                    if (caller.isReverse){
                        if (!caller.hasPrev){
                            caller.getlist("prev");
                        }
                    } else {
                        if (!caller.hasMore){
                            caller.getlist("next");
                        }
                    }
                    pageStack.pop();
                }
        Script.addPost(opt, s, f);
    } else {
        opt = {
            fid: caller.forum.id,
            kw: caller.forum.name,
            title: titlefield.text,
            content: content
        }
        if (voiceMd5){
            opt.during_time = Math.floor(attachedArea.audioDuration/1000);
            opt.voice_md5 = voiceMd5;
        }
        if (vcode){
            opt.vcode = vcode;
            opt.vcode_md5 = vcodeMd5;
        }
        if (tbsettings.signature !== "")
            opt.content += "\n"+tbsettings.signature;
        loading = true;
        s = function(){
                    tbsettings.draftBox = "";
                    loading = false;
                    signalCenter.showMessage(qsTr("Success"));
                    caller.getlist();
                    pageStack.pop();
                }
        Script.addThread(opt, s, f);
    }
}

function isVoiceUpload(){
    var isVoiceUrl = /voice/.test(uploader.url.toString());
    return isVoiceUrl;
}

function uploadFailed(){
    if (isVoiceUpload())
        voiceUploaded = true;
    else
        imageCursor ++;
    chunkFileOffset = 0;
    postTimer.start();
}

function uploadFinished(response){
    var isVoice = isVoiceUpload();
    var obj = JSON.parse(response);
    var offset, length, opt, s, f = function(err){
        console.log(err); postTimer.start();
    }

    if (obj.error && obj.error.errno != "0"){
        if (isVoice) voiceUploaded = true;
        else imageCursor ++;;
        chunkFileOffset = 0;

        postTimer.start();
        return;
    }

    if (isVoice){
        offset = Number(obj.chunk_offset);
        length = Number(obj.chunk_length);
        if (offset + length >= Number(obj.total_length)){
            voiceUploaded = true;
            chunkFileOffset = 0;

            opt = { voiceMd5: obj.total_file_md5 }
            s = function(obj){
                        if (obj.error && obj.error.errno != "0"){
                            console.log(JSON.stringify(obj));
                        } else {
                            voiceMd5 = obj.info.voice_md5;
                        }
                        postTimer.start();
                    }
            Script.voiceFinChunkUpload(opt, s, f);
        } else {
            chunkFileOffset = offset + length;
            postTimer.start();
        }
    } else {
        imageCursor ++;
        var info = JSON.parse(response).info;
        imageInfoList.push({id: info.pic_id, width: info.width, height: info.height});
        postTimer.start();
        //        offset = chunkFileOffset;
        //        length = 51200;
        //        var fn = attachedArea.imageList[imageCursor];

        //        if (offset + length >= utility.fileSize(fn)){
        //            imageCursor ++;
        //            chunkFileOffset = 0;

        //            opt = { md5: utility.fileHash(fn) }
        //            s = function(obj){
        //                        if (obj.error && obj.error.errno != "0"){
        //                            console.log(JSON.stringify(obj));
        //                        } else {
        //                            var info = obj.info;
        //                            imageInfoList.push({id: info.pic_id, width: info.width, height: info.height});
        //                        }
        //                        postTimer.start();
        //                    }
        //            Script.imageFinChunkUpload(opt, s, f);
        //        } else {
        //            chunkFileOffset = offset + length;
        //            postTimer.start();
        //        }
    }
}
