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
    _client_version: "5.0.4"
}

var BaiduApi = {
    TOKEN: "fb13bad79b3a1fefc0a5819a0b66eaa3e064a3bdf020f7f453a8ef905fd51aef",
    C_S_SYNC: HOST + "/c/s/sync",
    C_S_LOGIN: HOST + "/c/s/login",
    C_S_MSG: HOST + "/c/s/msg",
    C_S_COMLIST: HOST + "/c/s/comlist",
    C_S_SEARCHPOST: HOST + "/c/s/searchpost",

    C_F_FORUM_FORUMRECOMMEND: HOST + "/c/f/forum/forumrecommend",
    C_F_FORUM_LIKE: HOST + "/c/f/forum/like",
    C_F_FORUM_SUG: HOST + "/c/f/forum/sug",
    C_F_FRS_PAGE: HOST + "/c/f/frs/page",
    C_F_FRS_THREADLIST: HOST + "/c/f/frs/threadlist",
    C_F_FRS_PHOTOLIST: HOST + "/c/f/frs/photolist",
    C_F_FRS_PHOTO: HOST + "/c/f/frs/photo",
    C_F_PB_PAGE: HOST + "/c/f/pb/page",
    C_F_PB_FLOOR: HOST + "/c/f/pb/floor",
    C_F_PB_PICPAGE: HOST + "/c/f/pb/picpage",
    C_F_PB_PICCOMMENT: HOST + "/c/f/pb/piccomment",

    C_C_POST_ADD: HOST + "/c/c/post/add",
    C_C_THREAD_ADD: HOST + "/c/c/thread/add",
    C_C_FORUM_SIGN: HOST + "/c/c/forum/sign",
    C_C_FORUM_LIKE: HOST + "/c/c/forum/like",
    C_C_IMG_UPLOAD: HOST + "/c/c/img/upload",
    C_C_VOICE_UPLOAD: HOST + "/c/c/voice/chunkupload",
    C_C_VOICE_FINUPLOAD: HOST + "/c/c/voice/voice_fin_chunk_upload",

    C_U_FEED_REPLYME: HOST + "/c/u/feed/replyme",
    C_U_FEED_ATME: HOST + "/c/u/feed/atme",
    C_U_FEED_FORUM: HOST + "/c/u/feed/forum",
    C_U_USER_PROFILE: HOST + "/c/u/user/profile"
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
                        if (xhr.readyState === xhr.DONE){
                            if (xhr.status === 200){
                                try {
                                    var obj = JSON.parse(xhr.responseText);
                                    if (obj.error_code === "0"){
                                        onSuccess(obj);
                                    } else {
                                        var errMsg = obj.error ? obj.error.usermsg : obj.error_msg;
                                        onFailed(errMsg, obj);
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
