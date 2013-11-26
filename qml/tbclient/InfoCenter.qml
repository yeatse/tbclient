import QtQuick 1.1
import com.nokia.extras 1.1
import "../js/main.js" as Script

Item {
    id: root;

    property int fans: 0;
    property int replyme: 0;
    property int atme: 0;
    property int pletter: 0;
    property int bookmark: 0;
    property int count: 0;

    property bool loading: false;

    function clear(type){
        if (root.hasOwnProperty(type))
            root[type] = 0;
    }

    enabled: false;

    Connections {
        target: signalCenter;
        onUserChanged: {
            root.enabled = true;
        }
        onUserLogout: {
            root.enabled = false;
        }
    }

    Connections {
        target: Qt.application;
        onActiveChanged: {
            if (Qt.application.active){
                internal.displayMessage();
            }
        }
    }

    QtObject {
        id: internal;

        function loadMessage(obj){
            loading = false;
            for (var i in obj.message){
                if (root.hasOwnProperty(i)){
                    root[i] = Number(obj.message[i]);
                }
            }
            displayMessage();
        }

        function displayMessage(){
            if (Qt.application.active){
                var list = [];
                if (fans > 0){
                    infoBanner.type = "fans";
                    list.push(qsTr("%1 new fan(s)").arg(fans));
                }
                if (pletter > 0){
                    infoBanner.type = "pletter";
                    list.push(qsTr("%1 new pletter(s)").arg(pletter));
                }
                if (bookmark > 0){
                    infoBanner.type = "bookmark";
                    list.push(qsTr("%1 new bookmark update(s)").arg(bookmark));
                }
                if (replyme > 0){
                    infoBanner.type = "replyme";
                    list.push(qsTr("%1 new reply(ies)").arg(replyme));
                }
                if (atme > 0){
                    infoBanner.type = "atme";
                    list.push(qsTr("%1 new remind(s)").arg(atme));
                }
                if (list.length > 0){
                    infoBanner.text = list.join("\n");
                    infoBanner.open();
                }
            } else {
                var title = qsTr("Baidu Tieba");
                var message = qsTr("%1 new message(s)").arg(count);
                utility.showNotification(title, message);
            }
        }

        function loadError(err){
            loading = false;
            console.log(err);
        }
    }

    Timer {
        id: processingTimer;
        interval: tbsettings.remindInterval * 60 * 1000;
        repeat: true;
        triggeredOnStart: true;
        running: root.enabled
                 && tbsettings.remindInterval > 0
                 && (tbsettings.remindBackground||Qt.application.active);
        onTriggered: {
            loading = true;
            Script.getMessage(internal.loadMessage, internal.loadError);
        }
    }

    InfoBanner {
        id: infoBanner;
        property string type;
        interactive: true;
        platformInverted: tbsettings.whiteTheme;
    }
}
