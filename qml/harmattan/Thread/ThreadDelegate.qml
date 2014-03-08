import QtQuick 1.1
import "../Component"

AbstractItem {
    id: root;

    implicitHeight: contentCol.height + constant.paddingLarge;

    Column {
        id: contentCol;
        width: parent.width;
        spacing: constant.paddingMedium;
        Item {
            width: parent.width;
            height: constant.graphicSizeMedium;
            Image {
                id: avatar;
                width: constant.graphicSizeMedium;
                height: constant.graphicSizeMedium;
                sourceSize: constant.sizeMedium;
                source: authorPortrait;
                asynchronous: true;
                MouseArea {
                    anchors.fill: parent;
                    onClicked: signalCenter.linkClicked("at:"+authorId);
                }
            }
            Text {
                anchors {
                    left: avatar.right;
                    leftMargin: constant.paddingMedium;
                    verticalCenter: parent.verticalCenter;
                }
                text: authorName + "\nLv." + authorLevel;
                font: constant.subTitleFont;
                color: constant.colorMid;
            }
            Text {
                anchors.right: parent.right;
                text: floor + "#";
                font: constant.subTitleFont;
                color: constant.colorMid;
            }
        }
        Repeater {
            model: content;
            Loader {
                anchors {
                    left: parent.left; right: parent.right;
                    margins: constant.paddingLarge;
                }
                source: type + "Delegate.qml";
            }
        }
        Text {
            anchors { right: parent.right; rightMargin: constant.paddingSmall; }
            text: time;
            font: constant.subTitleFont;
            color: constant.colorMid;
        }
    }
    Row {
        anchors {
            left: parent.left;
            bottom: parent.bottom;
            margins: constant.paddingMedium;
        }
        visible: floor !== "1";
        Image {
            asynchronous: true;
            source: "../gfx/btn_icon_comment_n"+constant.invertedString;
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter;
            text: sub_post_number;
            font: constant.subTitleFont;
            color: constant.colorMid;
        }
    }
}
