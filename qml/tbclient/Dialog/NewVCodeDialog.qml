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
        height: platformContentMaximumHeight;
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
            onLoadFinished: coldDown2.start();
            Timer {
                id: coldDown;
                interval: 200;
                onTriggered: webView.url = "http://c.tieba.baidu.com/c/f/anti/gridcaptchaios";
            }
            Timer {
                id: coldDown2;
                interval: 200;
                onTriggered: {
                    if (/objc:/.test(webView.html)){
                        webView.html = webView.html.replace(/objc:/g, "javascript:window.objc.");
                    }
                }
            }
        }
    }

    onStatusChanged: {
        if (status === DialogStatus.Open){
            coldDown.start();
        } else if (status == DialogStatus.Closing){
            __isClosing = true;
        } else if (status == DialogStatus.Closed && __isClosing){
            root.destroy();
        }
    }
    Component.onCompleted: open();
}
