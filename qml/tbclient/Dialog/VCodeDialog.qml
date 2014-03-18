import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"

Sheet {
    id: root

    property variant caller: null;
    property string vcodeMd5: "";
    property string vcodePicUrl: "";

    property bool __isClosing: false;

    platformInverted: tbsettings.whiteTheme;

    acceptButtonText: qsTr("Continue");
    rejectButtonText: qsTr("Cancel");

    content: Flickable {
        anchors.fill: parent;
        contentWidth: parent.width;
        contentHeight: contentCol.height;
        boundsBehavior: Flickable.StopAtBounds;

        Column {
            id: contentCol;
            anchors.horizontalCenter: parent.horizontalCenter;
            spacing: constant.paddingLarge;
            Item { width: 1; height: 1; }
            ListItemText {
                anchors.horizontalCenter: parent.horizontalCenter;
                text: qsTr("Please input these characters");
            }
            Item {
                anchors.horizontalCenter: parent.horizontalCenter;
                width: 150; height: 60;
                Image {
                    id: pic;
                    cache: false;
                    asynchronous: true;
                    anchors.fill: parent;
                    smooth: true;
                    source: root.vcodePicUrl;
                }
                BusyIndicator {
                    anchors.centerIn: parent;
                    running: true;
                    visible: pic.status == Image.Loading;
                }
                MouseArea {
                    anchors.fill: parent;
                    onClicked: {
                        pic.source = "";
                        pic.source = root.vcodePicUrl;
                    }
                }
            }
            TextField {
                id: vcodeInput;
                width: 150;
                anchors.horizontalCenter: parent.horizontalCenter;
                placeholderText: qsTr("Input verify code");
                inputMethodHints: Qt.ImhNoPredictiveText|Qt.ImhNoAutoUppercase;
                Keys.onEnterPressed: accept();
                Keys.onReturnPressed: accept();
            }
        }
    }

    onAccepted: signalCenter.vcodeSent(caller, vcodeInput.text, root.vcodeMd5);

    Component.onCompleted: open();
    onStatusChanged: {
        if (status === DialogStatus.Open){
            vcodeInput.forceActiveFocus();
            vcodeInput.openSoftwareInputPanel();
        } else if (status === DialogStatus.Closing){
            __isClosing = true;
        } else if (status === DialogStatus.Closed && __isClosing){
            root.destroy();
        }
    }
}
