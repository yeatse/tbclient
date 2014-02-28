import QtQuick 1.1
import com.yeatse.tbclient 1.0
import "../js/main.js" as Script

Item {
    id: root;

    property int fans: 0;
    property int replyme: 0;
    property int atme: 0;
    property int pletter: 0;
    property int bookmark: 0;

    property bool loading: false;

    function clear(type){
        if (root.hasOwnProperty(type))
            root[type] = 0;
        internal.displayMessage();
    }

    enabled: false;

    Connections {
        target: signalCenter;
        onUserChanged: {
            root.enabled = true;
            processingTimer.triggered();
        }
        onUserLogout: {
            root.enabled = false;
        }
    }

    Connections {
        target: Qt.application;
        onActiveChanged: {
            if (!Qt.application.active){
                audioWrapper.stop();
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
            var list = [], count = 0;
            if (fans > 0 && tbsettings.remindFans){
                list.push(qsTr("%n new fan(s)", "", fans));
                count += fans;
            }
            if (pletter > 0 && tbsettings.remindPletter){
                list.push(qsTr("%n new pletter(s)", "", pletter));
                count += pletter;
            }
            if (bookmark > 0 && tbsettings.remindBookmark){
                list.push(qsTr("%n new bookmark update(s)", "", bookmark));
                count += bookmark;
            }
            if (replyme > 0 && tbsettings.remindReplyme){
                list.push(qsTr("%n new reply(ies)", "", replyme));
                count += replyme;
            }
            if (atme > 0 && tbsettings.remindAtme){
                list.push(qsTr("%n new remind(s)", "", atme));
                count += atme;
            }
            if (list.length > 0){
                var title = qsTr("Baidu Tieba");
                var message = list.join("\n");
                utility.showNotification(title, message);
            } else {
                utility.clearNotifications();
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
        running: root.enabled
                 && tbsettings.remindInterval > 0
                 && (tbsettings.remindBackground||Qt.application.active);
        onTriggered: {
            loading = true;
            Script.getMessage(internal.loadMessage, internal.loadError);
        }
    }
}
