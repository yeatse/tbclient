import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
    id: root;

    width: screen.width;
    height: contentCol.height + constant.paddingLarge*2;

    BorderImage {
        id: bgImg;
        anchors.fill: parent;
        source: privateStyle.imagePath("qtg_fr_list_heading_normal", tbsettings.whiteTheme);
        border { left: 28; top: 5; right: 28; bottom: 0; }
        smooth: true;
    }

    Column {
        id: contentCol;
        anchors {
            left: parent.left; top: parent.top; right: parent.right;
            margins: constant.paddingLarge;
        }
        spacing: constant.paddingLarge;
        Text {
            width: parent.width;
            elide: Text.ElideRight;
            wrapMode: Text.WrapAnywhere;
            maximumLineCount: 2;
            textFormat: Text.PlainText;
            font: constant.titleFont;
            color: constant.colorLight;
            text: thread ? thread.title : "";
        }
        Item {
            width: parent.width;
            height: childrenRect.height;
            Rectangle {
                id: forumBtn;
                width: forumLabel.width + constant.paddingLarge;
                height: forumLabel.height + constant.paddingMedium;
                radius: 4;
                border { width: 1; color: Qt.darker(forumBtn.color) }
                color: Qt.darker("#1080dd", forumMouseArea.pressed?3:2);
                Text {
                    id: forumLabel;
                    anchors.centerIn: parent;
                    font: constant.subTitleFont;
                    color: constant.colorLight;
                    text: forum ? forum.name+qsTr("Bar") : "";
                }
                MouseArea {
                    id: forumMouseArea;
                    anchors.fill: parent;
                    onClicked: signalCenter.enterForum(forum.name);
                }
            }
            Image {
                anchors.right: parent.right;
                source: "../../gfx/icon_grade_middle_star_%1.png".arg(collectMouseArea.pressed||isCollected?"s":"n");
                MouseArea {
                    id: collectMouseArea;
                    enabled: !loading;
                    anchors.fill: parent;
                    onClicked: isCollected ? rmStore() : addStore();
                }
            }
        }
    }
}
