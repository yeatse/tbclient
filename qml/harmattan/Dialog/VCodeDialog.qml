import QtQuick 1.1
import com.nokia.meego 1.1

Sheet {
    id: root

    property variant caller;
    property string vcodeMd5;
    property string vcodePicUrl;

    property int __isPage;  //to make sheet happy
    property bool __isClosing: false;

    acceptButtonText: qsTr("Continue");
    rejectButtonText: qsTr("Cancel");

    content: Flickable {
        anchors.fill: parent;
        contentWidth: parent.width;
        contentHeight: contentCol.height;

        Column {
            id: contentCol;
            anchors.horizontalCenter: parent.horizontalCenter;
            spacing: constant.paddingLarge;
            Item { width: 1; height: 1; }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter;
                text: qsTr("Please input these characters");
                font: constant.titleFont;
                color: constant.colorLight;
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
            }
        }
    }

    onAccepted: signalCenter.vcodeSent(caller, vcodeInput.text, root.vcodeMd5);

    Component.onCompleted: open();
    onStatusChanged: {
        if (status === DialogStatus.Open){
            vcodeInput.forceActiveFocus();
            vcodeInput.platformOpenSoftwareInputPanel();
        } else if (status === DialogStatus.Closing){
            __isClosing = true;
        } else if (status === DialogStatus.Closed && __isClosing){
            root.destroy(500);
        }
    }
}
