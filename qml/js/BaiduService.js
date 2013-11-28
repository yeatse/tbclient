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
    _client_version: "5.0.3"
}

var BaiduApi = {
    token: "fb13bad79b3a1fefc0a5819a0b66eaa3e064a3bdf020f7f453a8ef905fd51aef",
    C_S_Sync: HOST + "/c/s/sync",
    C_S_Login: HOST + "/c/s/login",
    C_S_Msg: HOST + "/c/s/msg",
    C_S_Comlist: HOST + "/c/s/comlist",

    C_F_Forum_Forumrecommend: HOST + "/c/f/forum/forumrecommend",
    C_F_Frs_Page: HOST + "/c/f/frs/page",
    C_F_Frs_Threadlist: HOST + "/c/f/frs/threadlist",
    C_F_Frs_Photolist: HOST + "/c/f/frs/photolist",
    C_F_Frs_Photo: HOST + "/c/f/frs/photo",
    C_F_Pb_Page: HOST + "/c/f/pb/page",
    C_F_Pb_Floor: HOST + "/c/f/pb/floor",

    C_C_Post_Add: HOST + "/c/c/post/add",
    C_C_Forum_Sign: HOST + "/c/c/forum/sign",
    C_C_Forum_Like: HOST + "/c/c/forum/like",

    C_U_Feed_Replyme: HOST + "/c/u/feed/replyme",
    C_U_Feed_Atme: HOST + "/c/u/feed/atme"
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
                        this.action,
                        "\n",
                        this.encodedParameters);
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
