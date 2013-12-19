import QtQuick 1.1
import com.nokia.extras 1.1
import QtMobility.systeminfo 1.2
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
            if (Qt.application.active){
                internal.displayMessage();
            } else {
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
                infoBanner.type = "fans";
                list.push(qsTr("%1 new fan(s)").arg(fans));
                count += fans;
            }
            if (pletter > 0 && tbsettings.remindPletter){
                infoBanner.type = "pletter";
                list.push(qsTr("%1 new pletter(s)").arg(pletter));
                count += pletter;
            }
            if (bookmark > 0 && tbsettings.remindBookmark){
                infoBanner.type = "bookmark";
                list.push(qsTr("%1 new bookmark update(s)").arg(bookmark));
                count += bookmark;
            }
            if (replyme > 0 && tbsettings.remindReplyme){
                infoBanner.type = "replyme";
                list.push(qsTr("%1 new reply(ies)").arg(replyme));
                count += replyme;
            }
            if (atme > 0 && tbsettings.remindAtme){
                infoBanner.type = "atme";
                list.push(qsTr("%1 new remind(s)").arg(atme));
                count += atme;
            }
            if (list.length > 0){
                if (Qt.application.active){
                    infoBanner.text = list.join("\n");
                    infoBanner.open();
                } else {
                    var title = qsTr("Baidu Tieba");
                    var message = qsTr("%1 new message(s)").arg(count);
                    utility.showNotification(title, message);
                }
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

    InfoBanner {
        id: infoBanner;
        property string type;
        interactive: true;
        platformInverted: tbsettings.whiteTheme;
        onClicked: signalCenter.readMessage(type);
    }

    DeviceInfo {
        id: deviceInfo;
        monitorLockStatusChanges: true;
        onLockStatusChanged: {
            if (deviceInfo.lockStatus == DeviceInfo.UnknownLock){
                internal.displayMessage();
            }
        }
    }
}
