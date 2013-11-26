import QtQuick 1.1

QtObject {
    id: signalCenter;

    property variant vcodeDialogComp: null;
    property variant threaPage: null;

    signal userChanged;
    signal userLogout;
    signal vcodeSent(variant caller, string vcode, string vcodeMd5);

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
            vcodeDialogComp = Qt.createComponent("Dialog/VCodeDialog2.qml");
        }
        var prop = { caller: caller, vcodeMd5: vcodeMd5, vcodePicUrl: vcodePicUrl }
        vcodeDialogComp.createObject(pageStack.currentPage, prop);
    }

    function enterForum(name){
        pageStack.push(Qt.resolvedUrl("Forum/ForumPage.qml"), { name: name });
    }

    function enterThread(option){
        if (!threaPage)
            threaPage = Qt.createComponent("Thread/ThreadPage.qml").createObject(app);
        if (pageStack.currentPage !== threaPage)
            pageStack.push(threaPage);
        if (option)
            threaPage.addThreadView(option);
    }

    function readMessage(param){

    }
}
