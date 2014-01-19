function linkActivated(link){
    var l = link.split(":");
    switch(l[0]){
    case "at":
        viewProfile(l[1]);
        break;
    case "img":
        viewImage(link.substring(4));
        break;
    case "link":
        decodeLink(link.substring(5));
        break;
    case "video":
        loadVideo(link.substring(6));
        break;
    }
}

function decodeLink(url){
    var m = url.match(/(?:tieba|wapp).baidu.com\/(?:p\/|f\?.*z=|.*m\?kz=)(\d+)/);
    if (m) return enterThread({"threadId": m[1]});

    m = utility.hasForumName(url);
    if (m) return enterForum(m);

    openBrowser(url);
}

function loadVideo(url){
    var webMethod = function(){ openBrowser(url); }
    if (url.indexOf("youku.com") > 0){
        var v = url.match(/(?:id_|sid\/)([^\.\/]+)/);
        loadYouku(v[1], webMethod);
    } else {
        webMethod();
    }
}

function loadYouku(sid, onFailed){
    showMessage(qsTr("Loading video..."));
    var url = "http://api.3g.youku.com/videos/"+sid
            +"/download?point=1&pid=69b81504767483cf&format=1,4,6";
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function(){
                if (xhr.readyState === xhr.DONE){
                    var ok = false;
                    if (xhr.status === 200){
                        try {
                            var obj = JSON.parse(xhr.responseText);
                            if (obj.status === "success"){
                                if (obj["results"]["3gphd"].length>0){
                                    var url = obj["results"]["3gphd"][0].url;
                                    utility.launchPlayer(url);
                                    ok = true;
                                } else if (obj["results"]["mp4"].length>0){
                                    var u = [];
                                    obj["results"]["mp4"].forEach(function(value){u.push(value.url)});
                                    utility.launchPlayer(u.join("\n"));
                                    ok = true;
                                }
                            }
                        } catch(e){
                        }
                    }
                    if (!ok) onFailed();
                }
            }
    xhr.open("GET", url);
    xhr.send();
}
