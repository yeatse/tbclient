import QtQuick 1.1

QtObject {
    id: signalCenter;

    property variant vcodeDialogComp: null;
    property variant queryDialogComp: null;
    property variant threaPage: null;

    signal userChanged;
    signal userLogout;
    signal vcodeSent(variant caller, string vcode, string vcodeMd5);
    signal imageSelected(variant caller, string urls);
    onImageSelected: console.log(caller, urls);

    signal uploadFinished(variant caller, string response);
    signal uploadFailed(variant caller);

    function needAuthorization(forceLogin){
        if(pageStack.currentPage.objectName !== "LoginPage"){
            var prop = { forceLogin: forceLogin||false }
            pageStack.push(Qt.resolvedUrl("LoginPage.qml"), prop);
        }
    }

    function showMessage(msg){
        if (msg||false){
            infoBanner.text = msg;
            infoBanner.open();
        }
    }

    function needVCode(caller, vcodeMd5, vcodePicUrl){
        if (!vcodeDialogComp){
            vcodeDialogComp = Qt.createComponent("Dialog/VCodeDialog.qml");
        }
        var prop = { caller: caller, vcodeMd5: vcodeMd5, vcodePicUrl: vcodePicUrl }
        vcodeDialogComp.createObject(pageStack.currentPage, prop);
    }

    function createQueryDialog(title, message, acceptText, rejectText, acceptCallback, rejectCallback){
        if (!queryDialogComp){ queryDialogComp = Qt.createComponent("Dialog/DynamicQueryDialog.qml"); }
        var prop = { titleText: title, message: message.concat("\n"), acceptButtonText: acceptText, rejectButtonText: rejectText };
        var diag = queryDialogComp.createObject(pageStack.currentPage, prop);
        if (acceptCallback) diag.accepted.connect(acceptCallback);
        if (rejectCallback) diag.rejected.connect(rejectCallback);
    }

    function enterForum(name){
        var p = pageStack.find(function(page){return page.objectName === "ForumPage" && page.name === name});
        if (p) pageStack.pop(p);
        else pageStack.push(Qt.resolvedUrl("Forum/ForumPage.qml"), { name: name });
    }

    function enterThread(option){
        if (!threaPage)
            threaPage = Qt.createComponent("Thread/ThreadPage.qml").createObject(app);
        if (pageStack.currentPage !== threaPage)
            pageStack.push(threaPage);
        if (option)
            threaPage.addThreadView(option);
    }

    function enterFloor(tid, pid){
        var prop = { threadId: tid, postId: pid }
        pageStack.push(Qt.resolvedUrl("Floor/FloorPage.qml"), prop);
    }

    function openBrowser(url){
        if (tbsettings.browser == ""){
            pageStack.push(Qt.resolvedUrl("WebPage.qml"), {url: url});
        } else {
            utility.openURLDefault(url);
        }
    }

    function readMessage(param){
    }
}
