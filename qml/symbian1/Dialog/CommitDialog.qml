import QtQuick 1.0
import com.nokia.symbian 1.0
import "../Component"
import "../../js/main.js" as Script

CustomDialog {
    id: root;

    property string fname;
    property string fid;
    property string tid;
    property string username;

    property bool majorManager: false;
    property bool __isClosing: false;

    titleText: qsTr("Confirmation");
    buttonTexts: [qsTr("Ban ID"), qsTr("Cancel")];
    onButtonClicked: if (index === 0) accept();
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
    content: Item {
        id: container;
        width: platformContentMaximumWidth;
        height: Math.min(platformContentMaximumHeight,
                         contentCol.height);

        Flickable {
            id: flickable;
            anchors.fill: parent;
            clip: true;
            contentWidth: parent.width;
            contentHeight: contentCol.height;

            Column {
                id: contentCol;
                width: parent.width;
                spacing: constant.paddingMedium;
                Item { width: 1; height: 1; }
                Label {
                    x: constant.paddingLarge;
                    text: qsTr("User name:")+username;
                }
                Label {
                    x: constant.paddingLarge;
                    text: qsTr("Ban period:");
                }
                ButtonColumn {
                    id: buttonCol;
                    width: parent.width / 2;
                    anchors.horizontalCenter: parent.horizontalCenter;
                    spacing: constant.paddingLarge;
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
    }

    Component.onCompleted: open();
    onStatusChanged: {
        if (status === DialogStatus.Closing){
            __isClosing = true;
        } else if (status === DialogStatus.Closed && __isClosing){
            root.destroy();
        }
    }
}
