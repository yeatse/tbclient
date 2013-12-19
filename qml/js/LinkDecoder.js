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
    }
}

function decodeLink(url){
    var m;
    m = url.match(/(?:tieba|wapp).baidu.com\/(?:p\/|f\?.*z=|.*m\?kz=)(\d+)/);
    if (m) return enterThread({"threadId": m[1]});

    m = url.match(/c.tieba.baidu.com\/f\?.*kw=(.+)/);
    if (m) return enterForum(m[1]);

    m = url.match(/tieba.baidu.com\/f\?.*kw=(.+?)[&#]/);
    if (m) return enterForum(hexToString(m[1]));

    m = url.match(/tieba.baidu.com\/f\?.*kw=(.+)/);
    if (m) return enterForum(hexToString(m[1]));

    openBrowser(url);
}

function hexToString(raw){
    var i=0, res = "";
    while (i<raw.length){
        if (raw.charAt(i) != "%" || i+2>raw.length){
            res += raw.charCodeAt(i).toString(16);
            i ++;
        } else {
            res += raw.charAt(i+1) + raw.charAt(i+2);
            i += 3;
        }
    }
    return utility.decodeGBKHex(res);
}
