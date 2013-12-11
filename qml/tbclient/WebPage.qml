import QtQuick 1.1
import com.nokia.symbian 1.1
import QtWebKit 1.0
import com.yeatse.tbclient 1.0
import "Component"

MyPage {
    id: page;

    property alias url: webView.url;

    title: webView.title;

    tools: ToolBarLayout {
        ToolButtonWithTip {
            property bool isHold: false;
            toolTipText: webView.back.toolTip;
            iconSource: "toolbar-back";
            onClicked: webView.back.enabled && !isHold ? webView.back.trigger() : pageStack.pop();
            onPlatformPressAndHold: isHold = true;
            onPressedChanged: if (pressed) isHold = false;
        }
        ToolButtonWithTip {
            toolTipText: webView.reload.toolTip;
            iconSource: "toolbar-refresh";
            enabled: webView.reload.enabled;
            onClicked: webView.reload.trigger();
        }
        ToolButtonWithTip {
            toolTipText: qsTr("Open browser");
            iconSource: "../gfx/internet"+constant.invertedString+".svg";
            onClicked: utility.openURLDefault(webView.url);
        }
        ToolButtonWithTip {
            toolTipText: qsTr("Home page");
            iconSource: "toolbar-home";
            onClicked: url = "http://m.baidu.com/";
        }
    }

    Flickable {
        id: view;
        anchors.fill: parent;
        boundsBehavior: Flickable.StopAtBounds;
        contentWidth: webView.width;
        contentHeight: webView.height;

        CustomWebView {
            id: webView;
            preferredWidth: view.width;
            preferredHeight: view.height;
            smooth: !view.moving;
            settings {
                javascriptCanOpenWindows: true;
                javascriptCanAccessClipboard: true;
                offlineStorageDatabaseEnabled: true;
                offlineWebApplicationCacheEnabled: true;
                localStorageDatabaseEnabled: true;
            }
            onUrlChanged: {
                view.contentX = 0;
                view.contentY = 0;
                view.returnToBounds();
            }
            onLoadStarted: loading = true;
            onLoadFailed: loading = true;
            onLoadFinished: loading = false;
            onAlert: signalCenter.createQueryDialog(qsTr("Alert"),message,qsTr("OK"),"");
        }
    }

    ScrollDecorator { flickableItem: view; platformInverted: tbsettings.whiteTheme; }

    ProgressBar {
        anchors.top: parent.top;
        width: parent.width;
        platformInverted: tbsettings.whiteTheme;
        value: webView.progress;
        visible: loading;
    }

    // For keypad
    onStatusChanged: {
        if (status === PageStatus.Active){
            view.forceActiveFocus();
        }
    }
    Keys.onPressed: {
        switch (event.key){
        case Qt.Key_R: webView.reload.trigger(); event.accepted = true; break;
        }
    }
}
