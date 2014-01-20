import QtQuick 1.1
import com.nokia.symbian 1.1

Menu {
    id: root;
    MenuLayout {
        MenuItem {
            text: qsTr("Back");
            enabled: webView.back.enabled;
            onClicked: webView.back.trigger();
        }
        MenuItem {
            text: qsTr("Forward");
            enabled: webView.forward.enabled;
            onClicked: webView.forward.trigger();
        }
        MenuItem {
            text: qsTr("Open browser");
            onClicked: utility.openURLDefault(webView.url);
        }
        MenuItem {
            text: tbsettings.compatibilityMode ? qsTr("Switch to fast mode") : qsTr("Switch to compatibility mode");
            onClicked: {
                if (tbsettings.compatibilityMode){
                    pageStack.replace(Qt.resolvedUrl("WebViewPage.qml"), { url: url });
                } else {
                    pageStack.replace(Qt.resolvedUrl("WebPage.qml"), { url: url });
                }
                tbsettings.compatibilityMode = !tbsettings.compatibilityMode;
            }
        }
    }
}
