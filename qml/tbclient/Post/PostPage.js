var imageCursor = 0;
var imageInfoList = []; //id, width, height

var voiceUploaded = false;
var voiceOffset = 0;
var voiceMd5 = "";

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
        Script.uploadImage(page, attachedArea.imageList[imageCursor]);
        return;
    }
    if (!voiceUploaded && voiceOffset < utility.fileSize(attachedArea.audioFile)){
        Script.uploadVoice(page, attachedArea.audioFile, voiceOffset);
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
            signalCenter.needVCodeNew(page, obj.info.vcode_md5, obj.info.vcode_pic_url);
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
    if (isVoiceUpload) voiceUploaded = true;
    else imageCursor ++;
    postTimer.start();
}

function uploadFinished(response){
    if (isVoiceUpload()){
        var obj = JSON.parse(response);
        if (obj.error && obj.error.errno != "0"){
            voiceUploaded = true;
            postTimer.start();
            return;
        }
        var offset = Number(obj.chunk_offset);
        var length = Number(obj.chunk_length);
        if (offset+length >= Number(obj.total_length)){
            voiceUploaded = true;
            var opt = { voiceMd5: obj.total_file_md5 }
            var s = function(obj){
                if (obj.error && obj.error.errno != "0"){
                    console.log(JSON.stringify(obj));
                } else {
                    voiceMd5 = obj.info.voice_md5;
                }
                postTimer.start();
            }
            var f = function(err){ console.log(err); postTimer.start(); }
            Script.voiceFinChunkUpload(opt, s, f);
        } else {
            voiceOffset = offset + length;
            postTimer.start();
        }
    } else {
        imageCursor ++;
        var info = JSON.parse(response).info;
        imageInfoList.push({id: info.pic_id, width: info.width, height: info.height});
        postTimer.start();
    }
}
