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
    var u = DBHelper.loadAuthData(aUid);
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
        _phone_screen: "360,640",
        _os_version: "6.1.3"
    }
    req.signForm(param);
    var s = function(obj){ tbsettings.clientId = obj.client.client_id; }
    var f = function(err){ console.log(err) }
    req.sendRequest(s, f);
}

// Required after userChanged signal emitted
function register(){
    var req = new BaiduRequest(BaiduApi.C_M_REGISTER);
    var param = {
        token: BaiduApi.TOKEN,
        os: "ios",
        uid: tbsettings.currentUid
    }
    req.signForm(param);
    var cb = new Function();
    req.sendRequest(cb, cb);
}

function login(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_S_LOGIN);
    var isp = option.isphone?1:0;
    var param = {
        token: BaiduApi.TOKEN,
        isphone: isp,
        m_api: "/c/s/sync",
        passwd: Qt.btoa(option.passwd),
        un: option.un
    }
    if (option.vcode){
        param.vcode = option.vcode;
        param.vcode_md5 = option.vcode_md5;
    }
    req.signForm(param);
    var s = function(obj){
        tbs = obj.anti.tbs;
        var user = obj.user;
        tbsettings.currentUid = user.id;
        DBHelper.storeAuthData(user.id, user.name, user.BDUSS, user.passwd, user.portrait);
        __name = user.name;
        __bduss = user.BDUSS;
        __portrait = user.portrait;
        BaiduConst.BDUSS = user.BDUSS;
        signalCenter.clearLocalCache();
        // Required after changing/adding an account
        BaiduRequest.intercomm();
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
    var s = function(obj){
        BaiduParser.loadLikeForum(option.model, obj.like_forum||[]);
        if (!workerScript.running){
            var msg = { func: "storeLikeForum", param: obj.like_forum||[] };
            workerScript.sendMessage(msg);
        }
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
    var s = function(obj){
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
        BaiduParser.loadForumPage(option, obj.thread_list||[]);
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
    var s = function(obj){
        var page = option.page;
        page.cursor = option.cursor + obj.thread_list.length;
        BaiduParser.loadForumPage(option, obj.thread_list||[]);
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
    var s = function(obj){
        tbs = obj.anti.tbs;
        var page = option.page;
        page.forum = obj.forum;
        var photoData = obj.photo_data;
        page.hasMore = photoData.has_more === "1";
        page.batchStart = photoData.batch_start;
        page.batchEnd = photoData.batch_end;
        page.photolist = photoData.alb_id_list;
        page.cursor = photoData.current_amount;
        BaiduParser.loadForumPicture(option, photoData.thread_list||[]);
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
    var s = function(obj){
        var list = obj.photo_data.thread_list;
        option.page.cursor += list.length;
        BaiduParser.loadForumPicture(option, list||[]);
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function getThreadPage(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_F_PB_PAGE);
    var param = {
        r: option.r||0,
        kz: option.kz
    }
    if (option.arround){
        param.arround = 20;
        if (option.renew) param.mark = 1;
        param.pid = option.pid;
    } else {
        param.pn = option.pn||1;
        param.rn = 20;
    }
    if (option.lz) param.lz = 1;
    if (option.st_type) param.st_type = option.st_type;
    req.signForm(param);
    var s = function(obj){
        tbs = obj.anti.tbs;
        var modelAffected = BaiduParser.loadThreadPage(option, obj.post_list||[]);
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
    var s = function(obj){
        var page = option.page;
        page.hasMore = obj.has_more === "1";
        page.currentPage = option.pn;
        BaiduParser.loadComlist(option, obj.record||[]);
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
    var s = function(obj){
        var page = option.page;
        page.hasMore = obj.page.has_more === "1";
        page.currentPage = obj.page.current_page;
        BaiduParser.loadReplyme(option, obj.reply_list||[]);
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
    var s = function(obj){
        var page = option.page;
        page.hasMore = obj.page.has_more === "1";
        page.currentPage = obj.page.current_page;
        BaiduParser.loadAtme(option, obj.at_list||[]);
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
        kz: option.kz
    };
    if (option.pid) param.pid = option.pid;
    else if (option.spid) param.spid = option.spid;
    req.signForm(param);
    var s = function(obj){
        tbs = obj.anti.tbs;
        var page = option.page;
        page.forum = obj.forum;
        page.thread = obj.thread;
        page.post = obj.post;
        page.currentPage = obj.page.current_page;
        page.pageSize = obj.page.page_size;
        page.totalPage = obj.page.total_page;
        page.totalCount = obj.page.total_count||0;
        BaiduParser.loadFloorPage(option, obj.subpost_list||[]);
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
    if (option.vcode){
        param.vcode = option.vcode;
        param.vcode_md5 = option.vcode_md5;
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

function chunkUpload(caller, type, filename, offset){
    if (uploader.uploadState == 2)
        uploader.abort();
    var chunkLength = type === "Image" ? 51200 : 30720;
    var chunk = utility.chunkFile(filename, offset, chunkLength);
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
        chunk_no: Math.floor(offset/chunkLength)+1,
        total_length: size,
        length: utility.fileSize(chunk),
        total_num: Math.ceil(size/chunkLength),
        offset: offset
    }
    if (type === "Image"){
        param.md5 = utility.fileHash(filename);
    } else {
        param.voice_md5 = utility.fileHash(filename);
    }
    for (var i in param){
        paramArray.push(i+"="+param[i]);
    }
    paramArray = paramArray.sort();
    var tmp = decodeURIComponent(paramArray.join(""))+"tiebaclient!!!";
    var sign = Qt.md5(tmp).toUpperCase();
    paramArray.push("sign="+sign);

    if (type === "Image"){
        uploader.open(BaiduApi.C_C_IMG_CHUNKUPLOAD);
    } else {
        uploader.open(BaiduApi.C_C_VOICE_UPLOAD);
    }
    paramArray.forEach(function(value){
                           var eq = value.indexOf("=");
                           uploader.addField(value.substring(0, eq), value.substring(eq+1));
                       });
    if (type === "Image"){
        uploader.addFile("pic_chunk", chunk);
    } else {
        uploader.addFile("voice_chunk", chunk);
    }
    uploader.send();
}

function uploadAvatar(caller, filename){
    if (uploader.uploadState == 2)
        uploader.abort();
    uploader.caller = caller;
    uploader.open(BaiduApi.C_C_IMG_PORTRAIT);
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
    uploader.addField("pic_type", 1);
    uploader.addFile("pic", filename);
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

function imageFinChunkUpload(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_C_IMG_FINUPLOAD);
    var param = { pic_type: 0, md5: option.md5 }
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
    if (option.vcode){
        param.vcode = option.vcode;
        param.vcode_md5 = option.vcode_md5;
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
    if (option.vcode){
        param.vcode = option.vcode;
        param.vcode_md5 = option.vcode_md5;
    }
    req.signForm(param);
    req.sendRequest(onSuccess, onFailed);
}

function forumSuggest(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_F_FORUM_SUG);
    var param = { q: option.q }
    req.signForm(param);
    var s = function(obj){
        BaiduParser.loadForumSuggest(option, obj.fname||[]);
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
    var s = function(obj){
        var page = option.page;
        page.currentPage = obj.page.current_page;
        page.hasMore = obj.page.has_more === "1";
        BaiduParser.loadSearchPost(option, obj.post_list||[]);
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
    var s = function(obj){
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
    var s = function(obj){
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
    var s = function(obj){
        var page = option.page;
        page.total = obj.total||0;
        page.hasMore = obj.has_more === "1";
        page.currentPage = option.pn;
        BaiduParser.loadForumFeed(option, obj.feed_thread_list||[]);
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function getUserProfile(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_U_USER_PROFILE);
    var param = { uid: option.uid };
    req.signForm(param);
    var s = function(obj){
        tbs = obj.anti.tbs;
        onSuccess(obj.user);
    }
    req.sendRequest(s, onFailed);
}

function getUserLikedForum(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_F_FORUM_LIKE);
    var param = { uid: option.uid, pn: 1 };
    req.signForm(param);
    var s = function(obj){
        BaiduParser.loadUserLikedForum(option.model, obj.forum_list||[]);
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function unfavforum(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_C_FORUM_UNFAVOLIKE);
    var param = { fid: option.fid, favo_type: option.favo_type, tbs: tbs, kw: option.kw };
    req.signForm(param);
    req.sendRequest(onSuccess, onFailed);
}

function getMyPost(option, onSuccess, onFailed){
    var isMe = option.user_id === tbsettings.currentUid;
    var req = new BaiduRequest(isMe ? BaiduApi.C_U_FEED_MYPOST
                                    : BaiduApi.C_U_FEED_OTHERPOST);
    var param = { pn: option.pn };
    if (isMe) param.type = 0;
    else param.user_id = option.user_id;

    req.signForm(param);
    var s = function(obj){
        if (obj.hide_post === "1"){
            onFailed("hide");
        } else {
            var page = option.page;
            page.currentPage = obj.page.current_page;
            page.hasMore = obj.page.has_more === "1";
            BaiduParser.loadMyPost(option, obj.post_list||[]);
            onSuccess();
        }
    }
    req.sendRequest(s, onFailed);
}

function getUserPage(option, onSuccess, onFailed){
    var url = option.type === "follow" ? BaiduApi.C_U_FOLLOW_PAGE
                                       : BaiduApi.C_U_FANS_PAGE;
    var req = new BaiduRequest(url);
    var param = { uid: option.uid };
    if (option.rn) param.rn = option.rn;
    if (option.pn) param.pn = option.pn;
    req.signForm(param);
    var s = function(obj){
        var page = option.page;
        page.currentPage = obj.page.current_page;
        page.hasMore = obj.page.has_more === "1";
        page.totalCount = obj.page.total_count;
        BaiduParser.loadUserList(option, obj.user_list||[]);
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function getBookmark(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_F_POST_THREADSTORE);
    var param = {
        user_id: tbsettings.currentUid,
        rn: 20,
        offset: option.offset
    }
    req.signForm(param);
    var s = function(obj){
        BaiduParser.loadBookmark(option, obj.store_thread||[]);
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function setBookmark(option, onSuccess, onFailed){
    signalCenter.bookmarkChanged();
    var url = option.add ? BaiduApi.C_C_POST_ADDSTORE : BaiduApi.C_C_POST_RMSTORE;
    var req = new BaiduRequest(url);
    var param = {};
    if (option.add){
        var t1 = [{ tid: option.tid, pid: option.pid, status: option.status }];
        param.data = JSON.stringify(t1);
    } else {
        param.tid = option.tid;
    }
    req.signForm(param);
    req.sendRequest(onSuccess, onFailed);
}

function deleteChatMsg(option, onSuccess, onFailed){
    var url = option.clear ? BaiduApi.C_S_CLEARMSG : BaiduApi.C_S_DELCOM;
    var req = new BaiduRequest(url);
    var param = { com_id: option.com_id, user_id: tbsettings.currentUid }
    req.signForm(param);
    req.sendRequest(onSuccess, onFailed)
}

function getChatMsg(option, onSuccess, onFailed){
    var url = option.history ? BaiduApi.C_S_HISTORYMSG : BaiduApi.C_S_RECENTMSG;
    var req = new BaiduRequest(url);
    var param = {
        user_id: tbsettings.currentUid,
        com_id: option.com_id,
        msg_id: option.msg_id
    }
    req.signForm(param);
    var s = function(obj){
        option.page.hasMore = obj.has_more === "1";
        BaiduParser.loadChatList(option, obj.message||[]);
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function addChatMsg(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_S_ADDMSG);
    var param = {
        user_id: tbsettings.currentUid,
        com_id: option.com_id,
        content: option.content
    }
    req.signForm(param);
    req.sendRequest(onSuccess, onFailed);
}

function followUser(option, onSuccess, onFailed){
    var url = option.isFollow ? BaiduApi.C_C_USER_FOLLOW : BaiduApi.C_C_USER_UNFOLLOW
    var req = new BaiduRequest(url);
    var param = { portrait: option.portrait, tbs: tbs };
    req.signForm(param);
    req.sendRequest(onSuccess, onFailed);
}

function getFollowSug(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_U_FOLLOW_SUG);
    var param = { uid: tbsettings.currentUid, q: option.q }
    req.signForm(param);
    var s = function(obj){onSuccess(obj.uname)};
    req.sendRequest(s, onFailed);
}

function getForumListForSign(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_F_FORUM_GETFORUMLIST);
    req.signForm();
    var s = function(obj){
        var page = option.page;
        page.signedCount = BaiduParser.loadForumForSign(option, obj.forum_info||[]);
        page.info = obj;
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function batchSign(option, onSuccess, onFailed){
    var s = function(){
        var req = new BaiduRequest(BaiduApi.C_C_FORUM_MSIGN);
        var param = {
            forum_ids: option.forum_ids.join(","),
            tbs: tbs
        }
        req.signForm(param);
        req.sendRequest(onSuccess, onFailed);
    }
    BaiduRequest.getTBS(s, onFailed);
}

function getForumSquare(onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_F_FORUM_FORUMSQUARE);
    req.signForm();
    req.sendRequest(onSuccess, onFailed);
}

function getForumSquareList(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_F_FORUM_FORUMSQUARELIST);
    var param = {
        list_id: option.list_id,
        st_type: option.st_type,
        rn: 10,
        offset: option.offset
    }
    req.signForm(param);
    var s = function(obj){
        var page = option.page;
        page.hasMore = obj.has_more === "1";
        page.offset = option.offset + obj.forumsquare_list.length;
        BaiduParser.loadForumSquareList(option, obj.forumsquare_list||[]);
        onSuccess(obj.title);
    }
    req.sendRequest(s, onFailed);
}

function getForumDir(model, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_F_FORUM_FORUMDIR);
    req.signForm();
    var s = function(obj){
        BaiduParser.loadForumDir(model, obj.forum_dir||[]);
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function getForumDir2(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_F_FORUM_SECONDDIR);
    var param = {
        menu_type: option.menu_type,
        menu_name: option.menu_name,
        menu_id: option.menu_id
    }
    req.signForm(param);
    var s = function(obj){
        BaiduParser.loadForumDir2(option.model, obj.forum_dir);
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function getForumRank(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_F_FORUM_FORUMRANK);
    var param = {
        menu_type: option.menu_type,
        menu_name: option.menu_name
    }
    if (option.offset){
        param.offset = option.offset;
        param.rn = 40;
    }
    req.signForm(param);
    var s = function(obj){
        var page = option.page;
        var cls = obj.forum_class;
        if (Array.isArray(cls) && cls.length === 2){
            page.leftName = cls[0];
            page.rightName = cls[1];
        }
        var result = BaiduParser.loadForumRank(option, obj);
        page.hasMore = result[0];
        page.offset = option.offset + result[1];
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function modifyProfile(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_C_PROFILE_MODIFY);
    var param = {
        intro: option.intro,
        sex: option.sex,
        tbs: tbs
    }
    req.signForm(param);
    req.sendRequest(onSuccess, onFailed);
}

function delpost(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_C_BAWU_DELPOST);
    var isfloor = option.floor ? 1 : 0;
    var is_vipdel = option.vip ? 1 : 0;

    var param = {
        word: option.word,
        src: 1,
        fid: option.fid,
        isfloor: isfloor,
        tbs: tbs,
        is_vipdel: is_vipdel,
        z: option.tid,
        pid: option.pid
    }

    req.signForm(param);
    req.sendRequest(onSuccess, onFailed);
}

function delthread(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_C_BAWU_DELTHREAD);

    var param = {
        word: option.word,
        fid: option.fid,
        tbs: tbs,
        z: option.tid
    }

    req.signForm(param);
    req.sendRequest(onSuccess, onFailed);
}

function commitPrison(option){
    var req = new BaiduRequest(BaiduApi.C_C_BAWU_COMMITPRISON);

    var param = {
        word: option.word,
        fid: option.fid,
        day: option.day,
        ntn: "banid",
        tbs: tbs,
        z: option.tid,
        un: option.un
    }

    req.signForm(param);
    var s = function(){ signalCenter.showMessage(qsTr("Success")); }
    var f = function(err){ signalCenter.showMessage(err); }
    req.sendRequest(s, f);
}

function commitTop(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_C_BAWU_COMMITTOP);
    var ntn = option.set ? "set" : "";

    var param = {
        word: option.word,
        fid: option.fid,
        tbs: tbs,
        ntn: ntn,
        z: option.tid
    }

    req.signForm(param);
    req.sendRequest(onSuccess, onFailed);
}

function commitGood(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_C_BAWU_COMMITGOOD);
    var ntn = option.set ? "set" : "";

    var param = {
        word: option.word,
        fid: option.fid,
        tbs: tbs,
        ntn: ntn,
        z: option.tid
    }
    if (option.cid)
        param.cid = option.cid;

    req.signForm(param);
    req.sendRequest(onSuccess, onFailed);
}

function getGoodList(option, onSuccess, onFailed){
    var req = new BaiduRequest(BaiduApi.C_C_BAWU_GOODLIST);
    var param = { word: option.word }
    req.signForm(param);
    var s = function(obj){
        var list = BaiduParser.loadGoodList(obj.cates||[]);
        onSuccess(list);
    }
    req.signForm(param);
    req.sendRequest(s, onFailed);
}
