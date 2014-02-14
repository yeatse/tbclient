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
        if (!busyInd.visible){
            var input = webView.evaluateJavaScript("_captcha.getInput()");
            signalCenter.vcodeSent(caller, input, root.vcodeMd5);
        }
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
            function loadSource(){
                var xhr = new XMLHttpRequest();
                xhr.onreadystatechange = function(){
                            if (xhr.readyState === xhr.DONE){
                                busyInd.visible = false;
                                if (xhr.status === 200){
                                    var html = xhr.responseText;
                                    html = html.replace(/objc:/g, "javascript:window.objc.");
                                    webView.html = html;
                                }
                            }
                        }
                busyInd.visible = true;
                xhr.open("GET", "http://c.tieba.baidu.com/c/f/anti/gridcaptchaios?cuid="+Qt.md5(utility.imei).toUpperCase());
                xhr.send();
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
            webView.loadSource();
        } else if (status == DialogStatus.Closing){
            __isClosing = true;
        } else if (status == DialogStatus.Closed && __isClosing){
            root.destroy();
        }
    }
    Component.onCompleted: open();
}
