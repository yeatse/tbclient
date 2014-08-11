import QtQuick 1.0
import com.nokia.symbian 1.0
import "../Component"

CustomDialog {
    id: root;

    property variant caller: null;
    property bool __isClosing: false;

    titleText: qsTr("Select emoticon");
    //titleIcon: "../gfx/btn_insert_face.png";
    buttonTexts: [qsTr("Close")]
    content: Item {
        width: platformContentMaximumWidth;
        height: platformContentMaximumHeight;

        Item {
            id: iconTip;
            property variant target: null;
            property alias text: iconTipLabel.text;

            function show(target){
                var targetPos = parent.mapFromItem(target, 0, 0);
                x = targetPos.x + (target.width/2) - (iconTip.width/2);
                y = targetPos.y - (iconTip.height) - platformStyle.paddingMedium;
                visible = true;
                autoHider.restart();
            }
            z: 10;
            width: privateStyle.textWidth(text, constant.labelFont)+platformStyle.paddingMedium*4;
            height: privateStyle.fontHeight(constant.labelFont)+platformStyle.paddingMedium*2;
            visible: false;
            BorderImage {
                anchors.fill: parent
                source: privateStyle.imagePath("qtg_fr_tooltip");
                border { left: 20; top: 20; right: 20; bottom: 20 }
            }
            Text {
                id: iconTipLabel;
                color: platformStyle.colorNormalLight;
                font: constant.labelFont;
                anchors.fill: parent;
                verticalAlignment: Text.AlignVCenter;
                horizontalAlignment: Text.AlignHCenter;
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
            ToolButton {
                text: qsTr("Default");
                onClicked: tabGroup.currentTab = defaultEmo;
            }
            ToolButton {
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
                cellWidth: app.inPortrait ? Math.floor(parent.width / 5)
                                          : Math.floor(parent.width / 7);
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
                delegate: MenuItem {
                    text: modelData;
                    onClicked: {
                        signalCenter.emoticonSelected(caller, text);
                        root.accept();
                    }
                }
                ScrollDecorator {
                    flickableItem: textEmo;
                }
            }
        }
    }

    onClickedOutside: close();
    onStatusChanged: {
        if (status == DialogStatus.Closing){
            __isClosing = true;
        } else if (status == DialogStatus.Closed && __isClosing){
            root.destroy();
        } else if (status == DialogStatus.Open){
        }
    }
    Component.onCompleted: open();
}
