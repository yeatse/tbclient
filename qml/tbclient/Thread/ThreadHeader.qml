import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
    id: root;

    width: screen.width;
    height: contentCol.height + constant.paddingMedium*2;

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
            left: parent.left; leftMargin: constant.paddingLarge;
            right: parent.right; rightMargin: constant.paddingLarge;
            top: parent.top; topMargin: constant.paddingMedium;
        }
        spacing: constant.paddingSmall;
        Text {
            width: parent.width;
            elide: Text.ElideRight;
            wrapMode: Text.WrapAnywhere;
            maximumLineCount: 2;
            textFormat: Text.PlainText;
            font: constant.labelFont;
            color: constant.colorLight;
            text: thread ? thread.title : "";
        }
        Item {
            width: parent.width; height: privateStyle.tabBarHeightLandscape;
            ButtonRow {
                width: forumBtn.implicitWidth;
                height: parent.height;
                TabButton {
                    id: forumBtn;
                    height: parent.height;
                    text: forum ? forum.name + qsTr("Bar") : "";
                    onClicked: signalCenter.enterForum(forum.name);
                }
            }
            Image {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; }
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
