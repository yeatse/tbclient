import QtQuick 1.0
import "../Component"

AbstractItem {
    id: root;

    onClicked: signalCenter.enterForum(forum_name);

    Image {
        id: logo;
        asynchronous: true;
        anchors {
            left: root.paddingItem.left; top: root.paddingItem.top;
            bottom: root.paddingItem.bottom;
        }
        width: height;
        source: model.avatar;
    }
    Image {
        id: subItemIcon;
        asynchronous: true;
        anchors {
            right: parent.right;
            rightMargin: privateStyle.scrollBarThickness;
            verticalCenter: parent.verticalCenter;
        }
        source: privateStyle.imagePath("qtg_graf_drill_down_indicator");
        sourceSize.width: platformStyle.graphicSizeSmall;
        sourceSize.height: platformStyle.graphicSizeSmall;
    }
    Column {
        anchors {
            left: logo.right; leftMargin: constant.paddingMedium;
            right: subItemIcon.left;
            verticalCenter: parent.verticalCenter;
        }
        Text {
            width: parent.width;
            elide: Text.ElideRight;
            font: constant.labelFont;
            color: constant.colorLight;
            text: forum_name;
        }
        Row {
            width: parent.width;
            Text {
                width: parent.width / 2;
                elide: Text.ElideRight;
                font: constant.subTitleFont;
                color: constant.colorMid;
                text: qsTr("%1 members").arg(member_count);
            }
            Text {
                width: parent.width / 2;
                elide: Text.ElideRight;
                font: constant.subTitleFont;
                color: constant.colorMid;
                text: qsTr("%1 posts").arg(thread_count);
            }
        }
        Text {
            width: parent.width;
            elide: Text.ElideRight;
            font: constant.subTitleFont;
            color: constant.colorMid;
            text: slogan;
        }
    }
}
