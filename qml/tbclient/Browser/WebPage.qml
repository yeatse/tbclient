import QtQuick 1.1
import com.nokia.symbian 1.1
import com.yeatse.tbclient 1.0
import "../Component"

MyPage {
    id: page;

    property alias url: webView.url;

    title: webView.title;

    tools: ToolBarLayout {
        BackButton {}
        ToolButtonWithTip {
            toolTipText: loading ? webView.stop.toolTip : webView.reload.toolTip;
            iconSource: loading ? "../gfx/tb_close_stop"+constant.invertedString+".svg" : "toolbar-refresh";
            enabled: loading ? webView.stop.enabled : webView.reload.enabled;
            onClicked: loading ? webView.stop.trigger() : webView.reload.trigger();
        }
        ToolButtonWithTip {
            toolTipText: qsTr("Home page");
            iconSource: "../gfx/home_sousuo.png";
            onClicked: homeMenu.open();
        }
        ToolButtonWithTip {
            toolTipText: webView.locking ? qsTr("Locked") : qsTr("Unlocked");
            iconSource: webView.locking ? "../gfx/lock"+constant.invertedString+".svg" : "../gfx/unlock"+constant.invertedString+".svg";
            onClicked: {
                if (!webView.locking){
                    webView.locking = true;
                    webView.lockMoving();
                } else {
                    webView.locking = false;
                    webView.unlockMoving();
                }
            }
        }
        ToolButtonWithTip {
            toolTipText: qsTr("Menu");
            iconSource: "toolbar-menu";
            onClicked: mainMenu.open();
        }
    }

    WebView {
        id: webView;
        property bool locking: false;
        anchors.fill: parent;
        defaultFontSize: tbsettings.fontSize;
        onLoadStarted: page.loading = true;
        onLoadFinished: page.loading = false;
        onDownloadStarted: downloadInfo.open();
        onDownloadFinished: downloadInfo.close();
        onDownloadProgress: downloadInfo.info = progress;
    }

    ProgressBar {
        anchors.top: parent.top;
        width: parent.width;
        platformInverted: tbsettings.whiteTheme;
        value: webView.loadProgress;
        visible: loading;
    }

    WebHomeMenu { id: homeMenu; }
    WebDownloadInfo { id: downloadInfo; }
    WebMainMenu { id: mainMenu; }

    // For keypad
    onStatusChanged: {
        if (status === PageStatus.Active){
            webView.forceActiveFocus();
        }
    }
    Connections {
        target: platformPopupManager;
        onPopupStackDepthChanged: {
            if (platformPopupManager.popupStackDepth === 0
                    && page.status === PageStatus.Active){
                webView.forceActiveFocus();
            }
        }
    }
    Keys.onPressed: {
        switch (event.key){
        case Qt.Key_M: mainMenu.open(); event.accepted = true; break;
        case Qt.Key_R: webView.reload.trigger(); event.accepted = true; break;
        case Qt.Key_Left: webView.back.trigger(); event.accepted = true; break;
        case Qt.Key_Right: webView.forward.trigger(); event.accepted = true; break;
        }
    }
}
