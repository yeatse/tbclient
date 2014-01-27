.pragma library

var HOST = "http://c.tieba.baidu.com";

var BaiduConst = {
    _client_type: 1,
    from: "appstore",
    _phone_newimei: "",
    net_type: 3,
    cuid: "",
    ka: "open",
    _timestamp: 0,
    _phone_imei: "",
    _client_id: "0",
    _client_version: "5.1.3"
}

var BaiduApi = {
    TOKEN: "fb13bad79b3a1fefc0a5819a0b66eaa3e064a3bdf020f7f453a8ef905fd51aef",
    INTERCOMM: "http://passport.baidu.com/v2/intercomm/statistic",

    C_M_REGISTER: HOST + "/c/m/register",
    C_S_SYNC: HOST + "/c/s/sync",
    C_S_LOGIN: HOST + "/c/s/login",
    C_S_MSG: HOST + "/c/s/msg",
    C_S_COMLIST: HOST + "/c/s/comlist",
    C_S_DELCOM: HOST + "/c/s/delcom",
    C_S_SEARCHPOST: HOST + "/c/s/searchpost",
    C_S_RECENTMSG: HOST + "/c/s/recentmsg",
    C_S_HISTORYMSG: HOST + "/c/s/historymsg",
    C_S_ADDMSG: HOST + "/c/s/addmsg",
    C_S_CLEARMSG: HOST + "/c/s/clearmsg",

    C_F_FORUM_FORUMRECOMMEND: HOST + "/c/f/forum/forumrecommend",
    C_F_FORUM_FORUMSQUARE: HOST + "/c/f/forum/forumsquare",
    C_F_FORUM_FORUMSQUARELIST: HOST + "/c/f/forum/forumsquarelist",
    C_F_FORUM_LIKE: HOST + "/c/f/forum/like",
    C_F_FORUM_SUG: HOST + "/c/f/forum/sug",
    C_F_FORUM_GETFORUMLIST: HOST + "/c/f/forum/getforumlist",
    C_F_FORUM_FORUMDIR: HOST + "/c/f/forum/forumdir",
    C_F_FORUM_SECONDDIR: HOST + "/c/f/forum/seconddir",
    C_F_FORUM_FORUMRANK: HOST + "/c/f/forum/forumrank",
    C_F_FRS_PAGE: HOST + "/c/f/frs/page",
    C_F_FRS_THREADLIST: HOST + "/c/f/frs/threadlist",
    C_F_FRS_PHOTOLIST: HOST + "/c/f/frs/photolist",
    C_F_FRS_PHOTO: HOST + "/c/f/frs/photo",
    C_F_PB_PAGE: HOST + "/c/f/pb/page",
    C_F_PB_FLOOR: HOST + "/c/f/pb/floor",
    C_F_PB_PICPAGE: HOST + "/c/f/pb/picpage",
    C_F_PB_PICCOMMENT: HOST + "/c/f/pb/piccomment",
    C_F_POST_THREADSTORE: HOST + "/c/f/post/threadstore",

    C_C_POST_ADD: HOST + "/c/c/post/add",
    C_C_POST_RMSTORE: HOST + "/c/c/post/rmstore",
    C_C_POST_ADDSTORE: HOST + "/c/c/post/addstore",
    C_C_THREAD_ADD: HOST + "/c/c/thread/add",
    C_C_FORUM_SIGN: HOST + "/c/c/forum/sign",
    C_C_FORUM_MSIGN: HOST + "/c/c/forum/msign",
    C_C_FORUM_LIKE: HOST + "/c/c/forum/like",
    C_C_FORUM_UNFAVOLIKE: HOST + "/c/c/forum/unfavolike",
    C_C_IMG_UPLOAD: HOST + "/c/c/img/upload",
    C_C_IMG_CHUNKUPLOAD: HOST + "/c/c/img/chunkupload",
    C_C_IMG_FINUPLOAD: HOST + "/c/c/img/finupload",
    C_C_VOICE_UPLOAD: HOST + "/c/c/voice/chunkupload",
    C_C_VOICE_FINUPLOAD: HOST + "/c/c/voice/voice_fin_chunk_upload",
    C_C_USER_UNFOLLOW: HOST + "/c/c/user/unfollow",
    C_C_USER_FOLLOW: HOST + "/c/c/user/follow",
    C_C_PROFILE_MODIFY: HOST + "/c/c/profile/modify",
    C_C_IMG_PORTRAIT: HOST + "/c/c/img/portrait",

    C_C_BAWU_DELPOST: HOST + "/c/c/bawu/delpost",
    C_C_BAWU_DELTHREAD: HOST + "/c/c/bawu/delthread",
    C_C_BAWU_COMMITPRISON: HOST + "/c/c/bawu/commitprison",
    C_C_BAWU_COMMITTOP: HOST + "/c/c/bawu/committop",
    C_C_BAWU_GOODLIST: HOST + "/c/c/bawu/goodlist",
    C_C_BAWU_COMMITGOOD: HOST + "/c/c/bawu/commitgood",

    C_U_FEED_REPLYME: HOST + "/c/u/feed/replyme",
    C_U_FEED_ATME: HOST + "/c/u/feed/atme",
    C_U_FEED_FORUM: HOST + "/c/u/feed/forum",
    C_U_FEED_MYPOST: HOST + "/c/u/feed/mypost",
    C_U_FEED_OTHERPOST: HOST + "/c/u/feed/otherpost",
    C_U_USER_PROFILE: HOST + "/c/u/user/profile",
    C_U_FOLLOW_PAGE: HOST + "/c/u/follow/page",
    C_U_FANS_PAGE: HOST + "/c/u/fans/page",
    C_U_FOLLOW_SUG: HOST + "/c/u/follow/sug"
}

var BaiduRequest = function(action, method){
    this.action = action;
    this.method = method||"POST";
    this.parameters = {};
    this.encodedParameters = "";
}

BaiduRequest.prototype.signForm = function(param){
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
            this.parameters = param;
            if (param){
                for (var i in param){
                    paramArray.push(i+"="+encodeURIComponent(param[i]));
                }
            }
            paramArray = paramArray.sort();
            var tmp = decodeURIComponent(paramArray.join(""))+"tiebaclient!!!";
            var sign = Qt.md5(tmp).toUpperCase();
            paramArray.push("sign="+sign);
            var result = paramArray.join("&");
            this.encodedParameters = result;
        }

BaiduRequest.prototype.sendRequest = function(onSuccess, onFailed){
            console.log("==============\n",
                        this.method,
                        this.action);
            // onSuccess(obj)
            // onFailed(message, [obj]);
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function(){
                        if (xhr.readyState === xhr.HEADERS_RECEIVED){
                            tbsettings.currentBearerName = utility.currentBearerName();
                        } else if (xhr.readyState === xhr.DONE){
                            if (xhr.status === 200){
                                try {
                                    var obj = JSON.parse(xhr.responseText);
                                    if (obj.error_code !== "0"){
                                        onFailed(obj.error_msg, obj);
                                    } else if (obj.error && obj.error.errno !== "0"){
                                        onFailed(obj.error.usermsg, obj);
                                    } else {
                                        onSuccess(obj);
                                    }
                                } catch(e){
                                    onFailed(JSON.stringify(e));
                                }
                            } else {
                                onFailed(xhr.status);
                            }
                        }
                    }
            if (this.method === "POST"){
                var toPost = this.encodedParameters;
                xhr.open("POST", this.action);
                xhr.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
                xhr.setRequestHeader("Content-Length", toPost.length);
                xhr.send(toPost);
            }
        }

BaiduRequest.getTBS = function(onSuccess, onFailed){
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function(){
                        if (xhr.readyState === xhr.DONE){
                            if (xhr.status === 200){
                                try {
                                    tbs = JSON.parse(xhr.responseText).tbs;
                                    onSuccess();
                                } catch(e){
                                    onFailed(JSON.stringify(e));
                                }
                            }
                        }
                    }
            xhr.open("GET", "http://tieba.baidu.com/dc/common/tbs");
            xhr.send();
        }

BaiduRequest.intercomm = function(){
            var xhr = new XMLHttpRequest();
            var postData = "sName=1&appid=1&tpl=tb&devicetype=ios&bduss="+__bduss;
            xhr.open("POST", BaiduApi.INTERCOMM);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            xhr.setRequestHeader("Content-Length", postData.length);
            xhr.send(postData);
        }
