import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1

Sheet {
    id: root;

    property variant caller: null;
    property bool __isClosing: false;
    property int __isPage;  //to make sheet happy

    title: Text {
        font.pixelSize: constant.fontXXLarge;
        color: constant.colorLight;
        anchors { left: parent.left; leftMargin: constant.paddingXLarge; verticalCenter: parent.verticalCenter; }
        text: qsTr("Select emoticon");
    }

    acceptButtonText: qsTr("Close");

    content: Item {
        anchors.fill: parent;

        Item {
            id: iconTip;
            property variant target: null;
            property alias text: iconTipLabel.text;

            function show(target){
                var targetPos = parent.mapFromItem(target, 0, 0);
                x = targetPos.x + (target.width/2) - (iconTip.width/2);
                y = targetPos.y - (iconTip.height) - constant.paddingMedium;
                visible = true;
                autoHider.restart();
            }
            z: 10;
            width: iconTipLabel.width + constant.paddingMedium*4;
            height: 32;
            visible: false;
            BorderImage {
                source: "image://theme/meegotouch-countbubble-background-large";
                anchors.fill: parent
                border { left: 10; top: 10; right: 10; bottom: 10 }
            }
            Text {
                id: iconTipLabel
                height: parent.height
                y:1
                color: "#FFFFFF"
                font: constant.subTitleFont;
                anchors.horizontalCenter: parent.horizontalCenter
                verticalAlignment: Text.AlignVCenter
            }
            Timer {
                id: autoHider;
                interval: 1000;
                onTriggered: iconTip.visible = false;
            }
        }

        ButtonRow {
            id: buttonRow;
            anchors {
                top: parent.top;
                left: parent.left;
                right: parent.right;
                margins: constant.paddingMedium;
            }
            Button {
                text: qsTr("Default");
                onClicked: tabGroup.currentTab = defaultEmo;
            }
            Button {
                text: qsTr("Emoticon");
                onClicked: tabGroup.currentTab = textEmo;
            }
        }

        TabGroup {
            id: tabGroup;
            anchors {
                top: buttonRow.bottom;
                left: parent.left;
                right: parent.right;
                bottom: parent.bottom;
                topMargin: constant.paddingMedium;
            }
            currentTab: defaultEmo;
            GridView {
                id: defaultEmo;
                anchors.fill: parent;
                cellWidth: Math.floor(app.inPortrait ? width / 5 : width / 7);
                cellHeight: cellWidth;
                clip: true;
                model: signalCenter.emoticonModel;
                delegate: emoDelegate;
                Component {
                    id: emoDelegate;
                    Item {
                        width: defaultEmo.cellWidth;
                        height: defaultEmo.cellHeight;
                        opacity: mouseArea.pressed ? 0.7 : 1;
                        MouseArea {
                            id: mouseArea;
                            anchors.fill: parent;
                            onClicked: {
                                var text = utility.emoticonText(modelData);
                                iconTip.text = text;
                                iconTip.show(mouseArea);
                                signalCenter.emoticonSelected(caller, "#("+text+")");
                            }
                        }
                        Image {
                            id: icon;
                            anchors.centerIn: parent;
                            asynchronous: true;
                            source: utility.emoticonUrl(modelData);
                        }
                    }
                }
                ScrollDecorator {
                    flickableItem: defaultEmo;
                }
            }
            ListView {
                id: textEmo;
                anchors.fill: parent;
                clip: true;
                model: utility.customEmoticonList();
                delegate: Item {
                    width: parent.width;
                    height: 64;
                    Text {
                        text: modelData;
                        font: constant.titleFont;
                        color: constant.colorLight;
                        anchors {
                            left: parent.left;
                            leftMargin: constant.paddingLarge;
                            verticalCenter: parent.verticalCenter;
                        }
                    }

                    Rectangle {
                        id: backgroundRect
                        anchors.fill: parent
                        color: delegateMouseArea.pressed ? "#3D3D3D" : "transparent";
                    }

                    MouseArea {
                        id: delegateMouseArea;
                        anchors.fill: parent;
                        onClicked: {
                            signalCenter.emoticonSelected(caller, modelData);
                            root.accept();
                        }
                    }
                }
                ScrollDecorator {
                    flickableItem: textEmo;
                }
            }
        }
    }

    onStatusChanged: {
        if (status == DialogStatus.Closing){
            __isClosing = true;
        } else if (status == DialogStatus.Closed && __isClosing){
            root.destroy(250);
        } else if (status == DialogStatus.Open){
        }
    }
    Component.onCompleted: open();
}
