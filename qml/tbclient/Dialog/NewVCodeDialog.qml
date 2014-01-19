import QtQuick 1.1
import com.nokia.symbian 1.1
import QtWebKit 1.0

CommonDialog {
    id: root;

    property variant caller;
    property string vcodeMd5;
    property string vcodePicUrl;

    property bool __isClosing: false;

    platformInverted: true;

    titleText: qsTr("Please enter verify code:");
    buttonTexts: [qsTr("Continue"), qsTr("Cancel")];

    onButtonClicked: if (index === 0) accept();
    onAccepted: {
        var input = webView.evaluateJavaScript("_captcha.getInput()");
        signalCenter.vcodeSent(caller, input, root.vcodeMd5);
    }

    content: Item {
        width: platformContentMaximumWidth;
        height: width * 3/4;
        WebView {
            id: webView;

            javaScriptWindowObjects: QtObject {
                WebView.windowObjectName: "objc";
                function jsGetVcodeImageUrl(callback){
                    webView.evaluateJavaScript("_captcha.updateIos(\"%1\")".arg(root.vcodePicUrl));
                }
                function jsChangeVcode(callback){
                    webView.evaluateJavaScript("_captcha.updateIos(\"%1\")".arg(root.vcodePicUrl));
                }
            }

            anchors.fill: parent;
            preferredWidth: parent.width;
            preferredHeight: parent.height;
            onLoadStarted: busyInd.visible = true;
            onLoadFailed: busyInd.visible = false;
            onLoadFinished: { busyInd.visible = false; coldDown.start(); }
            Timer {
                id: coldDown;
                interval: 50;
                onTriggered: {
                    if (/objc:/.test(webView.html)){
                        webView.html = webView.html.replace(/objc:/g, "javascript:window.objc.");
                    }
                }
            }
        }
        BusyIndicator {
            id: busyInd;
            anchors.centerIn: parent;
            width: constant.graphicSizeMedium;
            height: constant.graphicSizeMedium;
            platformInverted: true;
            running: true;
            visible: false;
        }
    }

    onStatusChanged: {
        if (status === DialogStatus.Open){
            webView.url = "http://c.tieba.baidu.com/c/f/anti/gridcaptchaios"
        } else if (status == DialogStatus.Closing){
            __isClosing = true;
        } else if (status == DialogStatus.Closed && __isClosing){
            root.destroy(1000);
        }
    }
    Component.onCompleted: open();
}
