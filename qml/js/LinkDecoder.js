Qt.include("YoukuParser.js");

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
        decodeLink(link.substring(6));
        break;
    }
}

function decodeLink(url){
    var m = url.match(/(?:tieba|wapp).baidu.com\/(?:p\/|f\?.*z=|.*m\?kz=)(\d+)/);
    if (m) return enterThread({"threadId": m[1]});

    m = utility.hasForumName(url);
    if (m) return enterForum(m);

    url = utility.fixUrl(url);
    if (url.indexOf("youku.com") > 0){
        showMessage(qsTr("Loading video..."));
        query(url);
        return;
    }

    openBrowser(url);
}
