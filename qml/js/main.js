.pragma library

Qt.include("BaiduService.js");
Qt.include("storage.js");
Qt.include("BaiduParser.js");

var signalCenter, tbsettings, utility, workerScript, uploader;
var __name, __bduss, __portrait;
var tbs;

function initialize(sc, ts, ut, ws, ul){
    signalCenter = sc;
    tbsettings = ts;
    utility = ut;
    workerScript = ws;
    uploader = ul;
    if (checkAuthData(tbsettings.currentUid)){
        signalCenter.userChanged();
    } else {
        signalCenter.needAuthorization(true);
    }
}

function checkAuthData(aUid){
    if (tbsettings.clientId.length < 5)
        sync();
    var u = loadAuthData(aUid);
    if (u.length > 0){
        __name = u[0].name;
        __bduss = u[0].BDUSS;
        __portrait = u[0].portrait;
        BaiduConst.BDUSS = __bduss;
        return true;
    }
    return false;
}

function sync(){
    var req = new BaiduRequest(BaiduApi.C_S_SYNC);
    var param = {
        msg_status: 1,
        manager_model: 0,
        _active: 0,
        _phone_screen: "640,960",
        _os_version: "6.1.3"
    }
    req.signForm(param);
    function s(obj){ tbsettings.clientId = obj.client.client_id; }
    function f(err){ console.log(err) }
    req.sendRequest(s, f);
}

function login(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_S_LOGIN);
    var param = {
        token: BaiduApi.TOKEN,
        isphone: option.isphone?1:0,
                                 m_api: "/c/s/sync",
                                 passwd: Qt.btoa(option.passwd),
                                 un: option.un
    }
    if (option.vcode){
        param.vcode = option.vcode;
        param.vcode_md5 = option.vcode_md5;
    }
    req.signForm(param);
    function s(obj){
        tbs = obj.anti.tbs;
        var user = obj.user;
        tbsettings.currentUid = user.id;
        storeAuthData(user.id, user.name, user.BDUSS, user.passwd, user.portrait);
        __name = user.name;
        __bduss = user.BDUSS;
        __portrait = user.portrait;
        BaiduConst.BDUSS = user.BDUSS;
        signalCenter.userChanged();
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function getMessage(onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_S_MSG);
    var param = { bookmark: 1 }
    req.signForm(param);
    req.sendRequest(onSuccess, onFailed);
}

function getRecommentForum(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_F_FORUM_FORUMRECOMMEND);
    req.signForm();
    function s(obj){
        BaiduParser.loadLikeForum(option.model, obj.like_forum);
        var msg = { func: "storeLikeForum", param: obj.like_forum };
        workerScript.sendMessage(msg);
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function getForumPage(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_F_FRS_PAGE);
    var param = {
        rn_need: 30,
        with_group: 1,
        pn: option.pn||1,
        kw: option.kw,
        rn: 90
    }
    if (option.is_good){
        param.is_good = option.is_good;
        param.cid = option.cid;
    }
    req.signForm(param);
    function s(obj){
        tbs = obj.anti.tbs;
        var page = option.page;
        page.user = obj.user;
        page.forum = obj.forum;
        page.totalPage = obj.page.total_page;
        page.currentPage = obj.page.current_page;
        page.hasMore = obj.page.has_more === "1";
        page.hasPrev = obj.page.has_prev === "1";
        page.threadIdList = obj.thread_id_list;
        page.cursor = 0;
        page.curGoodId = obj.page.cur_good_id;
        BaiduParser.loadForumPage(option, obj.thread_list);
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function getThreadList(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_F_FRS_THREADLIST);
    var param = {
        thread_ids: option.thread_ids.join(","),
        forum_id: option.forum_id,
        need_abstract: 1
    }
    req.signForm(param);
    function s(obj){
        var page = option.page;
        page.cursor = option.cursor + obj.thread_list.length;
        BaiduParser.loadForumPage(option, obj.thread_list);
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function getPhotoPage(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_F_FRS_PHOTOLIST);
    var param = {
        an: 30,
        bs: option.bs,
        be: option.be,
        kw: option.kw
    }
    req.signForm(param);
    function s(obj){
        tbs = obj.anti.tbs;
        var page = option.page;
        page.forum = obj.forum;
        var photoData = obj.photo_data;
        page.hasMore = photoData.has_more === "1";
        page.batchStart = photoData.batch_start;
        page.batchEnd = photoData.batch_end;
        page.photolist = photoData.alb_id_list;
        page.cursor = photoData.current_amount;
        BaiduParser.loadForumPicture(option, photoData.thread_list);
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function getPhotoList(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_F_FRS_PHOTO);
    var param = {
        alb_ids: option.ids.join(","),
        kw: option.kw
    }
    req.signForm(param);
    function s(obj){
        var list = obj.photo_data.thread_list;
        option.page.cursor += list.length;
        BaiduParser.loadForumPicture(option, list);
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function getThreadPage(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_F_PB_PAGE);
    var param = {
        r: option.r||0,
        pn: option.pn||1,
        rn: 20,
        kz: option.kz
    }
    if (option.lz) param.lz = 1;
    req.signForm(param);
    function s(obj){
        tbs = obj.anti.tbs;
        var modelAffected = BaiduParser.loadThreadPage(option, obj.post_list);
        onSuccess(obj, modelAffected);
    }
    req.sendRequest(s, onFailed);
}

function getComlist(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_S_COMLIST);
    var param = {
        pn: option.pn,
        user_id: tbsettings.currentUid,
        rn: 50
    }
    req.signForm(param);
    function s(obj){
        var page = option.page;
        page.hasMore = obj.has_more === "1";
        page.currentPage = option.pn;
        BaiduParser.loadComlist(option, obj.record);
        if (option.renew){
            utility.setUserData("pletter", JSON.stringify(obj));
        }
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function getReplyme(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_U_FEED_REPLYME);
    var param = {
        uid: tbsettings.currentUid,
        pn: option.pn
    }
    req.signForm(param);
    function s(obj){
        var page = option.page;
        page.hasMore = obj.page.has_more === "1";
        page.currentPage = obj.page.current_page;
        BaiduParser.loadReplyme(option, obj.reply_list);
        if (option.renew){
            utility.setUserData("replyme", JSON.stringify(obj));
        }
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function getAtme(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_U_FEED_ATME);
    var param = {
        uid: tbsettings.currentUid,
        pn: option.pn
    }
    req.signForm(param);
    function s(obj){
        var page = option.page;
        page.hasMore = obj.page.has_more === "1";
        page.currentPage = obj.page.current_page;
        BaiduParser.loadAtme(option, obj.at_list);
        if (option.renew){
            utility.setUserData("atme", JSON.stringify(obj));
        }
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function sign(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_C_FORUM_SIGN);
    var param = {
        fid: option.fid,
        tbs: tbs,
        kw: option.kw,
        uid: tbsettings.currentUid
    }
    req.signForm(param);
    req.sendRequest(onSuccess, onFailed);
}

function likeForum(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_C_FORUM_LIKE);
    var param = {
        fid: option.fid,
        tbs: tbs,
        kw: option.kw
    }
    req.signForm(param);
    req.sendRequest(onSuccess, onFailed);
}

function getFloorPage(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_F_PB_FLOOR);
    var param = {
        pn: option.pn||1,
        pid: option.pid,
        kz: option.kz
    };
    req.signForm(param);
    function s(obj){
        tbs = obj.anti.tbs;
        var page = option.page;
        page.forum = obj.forum;
        page.thread = obj.thread;
        page.post = obj.post;
        page.currentPage = obj.page.current_page;
        page.pageSize = obj.page.page_size;
        page.totalPage = obj.page.total_page;
        page.totalCount = obj.page.total_count||0;
        BaiduParser.loadFloorPage(option, obj.subpost_list);
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function addThread(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_C_THREAD_ADD);
    var param = {
        during_time: option.during_time||"",
        fid: option.fid,
        new_vcode: 1,
        content: option.content,
        tbs: tbs,
        kw: option.kw,
        vcode_tag: 11,
        voice_md5: option.voice_md5||"",
        title: option.title,
        anonymous: 0
    }
    req.signForm(param);
    req.sendRequest(onSuccess, onFailed);
}

function uploadImage(caller, filename){
    if (uploader.uploadState == 2)
        uploader.abort();
    uploader.caller = caller;
    uploader.open(BaiduApi.C_C_IMG_UPLOAD);
    uploader.addField("net_type", BaiduConst.net_type);
    uploader.addField("ka", BaiduConst.ka);
    uploader.addField("_phone_imei", BaiduConst._phone_imei);
    uploader.addField("BDUSS", __bduss);
    uploader.addField("_timestamp", Date.now());
    uploader.addField("_client_version", BaiduConst._client_version);
    uploader.addField("_phone_newimei", BaiduConst._phone_newimei);
    uploader.addField("from", BaiduConst.from);
    uploader.addField("_client_type", BaiduConst._client_type);
    uploader.addField("_client_id", BaiduConst._client_id);
    uploader.addField("cuid", BaiduConst.cuid);
    uploader.addField("pic_type", 0);
    uploader.addFile("pic", filename);
    uploader.send();
}

function uploadVoice(caller, filename, offset){
    if (uploader.uploadState == 2)
        uploader.abort();
    var chunk = utility.chunkFile(filename, offset);
    var size = utility.fileSize(filename);

    uploader.caller = caller;
    BaiduConst._client_type = tbsettings.clientType;
    BaiduConst._phone_newimei = Qt.md5(utility.imei+"0").toUpperCase();
    BaiduConst.cuid = Qt.md5(utility.imei).toUpperCase();
    BaiduConst._timestamp = Date.now();
    BaiduConst._phone_imei = BaiduConst.cuid;
    BaiduConst._client_id = tbsettings.clientId;
    var paramArray = [];
    for (var i in BaiduConst){
        paramArray.push(i+"="+BaiduConst[i]);
    }
    var param = {
        chunk_md5: utility.fileHash(chunk),
        chunk_no: Math.floor(offset/30720)+1,
        total_length: size,
        length: utility.fileSize(chunk),
        voice_md5: utility.fileHash(filename),
        total_num: Math.ceil(size/30720),
        offset: offset
    }
    for (var i in param){
        paramArray.push(i+"="+param[i]);
    }
    paramArray = paramArray.sort();
    var tmp = decodeURIComponent(paramArray.join(""))+"tiebaclient!!!";
    var sign = Qt.md5(tmp).toUpperCase();
    paramArray.push("sign="+sign);

    uploader.open(BaiduApi.C_C_VOICE_UPLOAD);
    paramArray.forEach(function(value){
                           var eq = value.indexOf("=");
                           uploader.addField(value.substring(0, eq), value.substring(eq+1));
                       });
    uploader.addFile("voice_chunk", chunk);
    uploader.send();
}

function uploadStateChanged(){
    if (uploader.uploadState == 3){
        signalCenter.showMessage(qsTr("Operation canceled"));
    } else if (uploader.uploadState == 4){
        if (uploader.status === 200){
            signalCenter.uploadFinished(uploader.caller, uploader.responseText);
        } else {
            signalCenter.uploadFailed(uploader.caller);
        }
        uploader.clear();
    }
}

function voiceFinChunkUpload(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_C_VOICE_FINUPLOAD);
    var param = { voice_md5: option.voiceMd5 }
    req.signForm(param);
    req.sendRequest(onSuccess, onFailed);
}

function addPost(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_C_POST_ADD);
    var param = {
        tid: option.tid,
        fid: option.fid,
        new_vcode: 1,
        content: option.content,
        tbs: tbs,
        kw: option.kw,
        vcode_tag: 11,
        anonymous: 0,
        floor: 2
    }
    if (option.during_time){
        param.during_time = option.during_time;
        param.voice_md5 = option.voice_md5;
    }
    req.signForm(param);
    req.sendRequest(onSuccess, onFailed);
}

function floorReply(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_C_POST_ADD);
    var param = {
        floor_num: 0,
        tid: option.tid,
        fid: option.fid,
        new_vcode: 1,
        content: option.content,
        quote_id: option.quote_id,
        tbs: tbs,
        kw: option.kw,
        vcode_tag: 11,
        anonymous: 0
    }
    req.signForm(param);
    req.sendRequest(onSuccess, onFailed);
}

function forumSuggest(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_F_FORUM_SUG);
    var param = { q: option.q }
    req.signForm(param);
    function s(obj){
        BaiduParser.loadForumSuggest(option, obj.fname);
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function searchPost(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_S_SEARCHPOST);
    var param = {
        word: option.word,
        pn: option.pn||1,
        rn: 20
    }
    req.signForm(param);
    function s(obj){
        var page = option.page;
        page.currentPage = obj.page.current_page;
        page.hasMore = obj.page.has_more === "1";
        BaiduParser.loadSearchPost(option, obj.post_list);
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function getPicturePage(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_F_PB_PICPAGE);
    var param = {
        tid: option.tid,
        next: 20,
        prev: 0,
        kw: option.kw,
        pic_id: option.pic_id
    }
    req.signForm(param);
    function s(obj){
        var page = option.page;
        page.forum = obj.forum;
        page.picAmount = obj.pic_amount;
        BaiduParser.loadPicturePage(option, obj.pic_list||[]);
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function getPicComment(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_F_PB_PICCOMMENT);
    var param = {
        tid: option.tid,
        alt: "json",
        pn: option.pn,
        oc: 0,
        kw: option.kw,
        pic_id: option.pic_id,
        rn: 10
    }
    req.signForm(param);
    function s(obj){
        tbs = obj.tbs.common;
        var page = option.page;
        page.currentPage = obj.cur_page;
        page.totalPage = obj.total_page;
        BaiduParser.loadPicComment(option, obj.comment_list||[]);
        onSuccess(obj.comment_amount);
    }
    req.sendRequest(s, onFailed);
}

function getForumFeed(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_U_FEED_FORUM);
    var param = {
        rn: 20,
        pn: option.pn,
        user_id: tbsettings.currentUid
    }
    req.signForm(param);
    function s(obj){
        var page = option.page;
        page.total = obj.total||0;
        page.hasMore = obj.has_more === "1";
        page.currentPage = option.pn;
        BaiduParser.loadForumFeed(option, obj.feed_thread_list||[]);
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}
