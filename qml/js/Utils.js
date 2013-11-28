.pragma library

function getThumbnail(bigPic){
    if (bigPic.indexOf("http://imgsrc.baidu.com/forum/pic/item/") === 0){
        return "http://imgsrc.baidu.com/forum/abpic/item/"+bigPic.substring(39);
    } else {
        return bigPic;
    }
}

function getPortrait(portrait){
    if (portrait){
        return "http://tb.himg.baidu.com/sys/portraitn/item/"+portrait;
    } else {
        return Qt.resolvedUrl("../gfx/photo.png");
    }
}

function getAudioUrl(md5){
    return "http://c.tieba.baidu.com/c/p/voice?voice_md5="+md5;
}

function milliSecondsToString(milliseconds) {
    milliseconds = milliseconds > 0 ? milliseconds : 0;
    var timeInSeconds = Math.floor(milliseconds / 1000);
    var minutes = Math.floor(timeInSeconds / 60);
    var minutesString = minutes < 10 ? "0" + minutes : minutes;
    var seconds = Math.floor(timeInSeconds % 60);
    var secondsString = seconds < 10 ? "0" + seconds : seconds;
    return minutesString + ":" + secondsString;
}

function getEmoticon(text, c){
    return "["+c+"]"
}

var TextSlicer = {
    textLength: function(text){
                    return text.replace(/^[\x00-\xff]/g,"**").length;
                },
    slice: function(text, maxLength){
               var result = "";
               for (var i=0; this.textLength(result)<=maxLength && i<text.length; i++){
                   result += text.charAt(i);
               }
               return result;
           }
}
