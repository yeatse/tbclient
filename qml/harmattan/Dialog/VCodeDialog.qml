import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    id: root

    property variant caller;
    property string vcodeMd5;
    property string vcodePicUrl;

    property bool __isClosing: false;

    titleText: qsTr("Please enter verify code:");
    buttonTexts: [qsTr("Continue"), qsTr("Cancel")];

    content: Item {
        width: platformContentMaximumWidth;
        height: Math.min(platformContentMaximumHeight, contentCol.height);

        Flickable {
            anchors.fill: parent;
            clip: true;
            contentWidth: parent.width;
            contentHeight: contentCol.height;

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
                    width: 120; height: 48;
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
    }

    onButtonClicked: if (index === 0) accept();
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
