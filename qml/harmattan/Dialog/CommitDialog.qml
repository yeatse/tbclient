import QtQuick 1.1
import com.nokia.meego 1.1
import "../../js/main.js" as Script

Sheet {
    id: root;

    property string fname;
    property string fid;
    property string tid;
    property string username;

    property bool majorManager: false;
    property bool __isClosing: false;
    property int __isPage;  //to make sheet happy

    acceptButtonText: qsTr("Ban ID");
    rejectButtonText: qsTr("Cancel");

    onAccepted: {
        var opt = {
            word: fname,
            fid: fid,
            day: buttonCol.checkedButton.objectName.substring(3),
            tid: tid,
            un: username
        }
        Script.commitPrison(opt);
    }

    content: Flickable {
        id: flickable;
        anchors.fill: parent;
        clip: true;
        contentWidth: parent.width;
        contentHeight: contentCol.heigh+constant.paddingLarge*2;

        Column {
            id: contentCol;
            anchors {
                left: parent.left; top: parent.top;
                right: parent.right; margins: constant.paddingLarge;
            }
            spacing: constant.paddingMedium;
            Label {
                text: qsTr("User name:")+username;
            }
            Label {
                text: qsTr("Ban period:");
            }
            ButtonColumn {
                id: buttonCol;
                anchors.horizontalCenter: parent.horizontalCenter;
                Button {
                    objectName: "ban1";
                    width: parent.width;
                    text: qsTr("%n day(s)", "", 1);
                }
                Button {
                    objectName: "ban3";
                    width: parent.width;
                    text: qsTr("%n day(s)", "", 3);
                    visible: majorManager;
                }
                Button {
                    objectName: "ban10";
                    width: parent.width;
                    text: qsTr("%n day(s)", "", 10);
                    visible: majorManager;
                }
            }
        }
    }

    Component.onCompleted: open();
    onStatusChanged: {
        if (status === DialogStatus.Closing){
            __isClosing = true;
        } else if (status === DialogStatus.Closed && __isClosing){
            root.destroy(250);
        }
    }
}
