import QtQuick 1.0
import "../Component"

AbstractItem {
    id: root;
    implicitHeight: contentCol.height + constant.paddingLarge;
    onClicked: {
        var prop = { threadId: thread_id, title: title };
        signalCenter.enterThread(prop);
    }
    Column {
        id: contentCol;
        width: parent.width;
        spacing: constant.paddingSmall;
        Item {
            width: parent.width;
            height: feedLabel.height;
            BorderImage {
                id: feedLabel;
                asynchronous: true;
                source: "../gfx/bg_forum_feed_label.png";
                border { left: 10; right: 30; top: 0; bottom: 0; }
                width: feedLabelText.width + 40;
                Text {
                    id: feedLabelText;
                    anchors {
                        left: parent.left; leftMargin: 10;
                        verticalCenter: parent.verticalCenter;
                    }
                    text: forum_name;
                    font: constant.labelFont;
                    color: "white";
                }
            }
            Row {
                anchors {
                    right: parent.right; top: parent.top;
                    margins: constant.paddingMedium;
                }
                spacing: 2;
                Image {
                    asynchronous: true;
                    enabled: is_good;
                    visible: enabled;
                    source: enabled ? "../gfx/icon_elite.png" : "";
                }
                Image {
                    asynchronous: true;
                    enabled: is_top;
                    visible: enabled;
                    source: enabled ? "../gfx/icon_top.png" : "";
                }
            }
        }
        Text {
            anchors { left: parent.left; right: parent.right; margins: constant.paddingLarge; }
            text: title;
            color: constant.colorLight;
            font: constant.titleFont;
            wrapMode: Text.WrapAnywhere;
            textFormat: Text.PlainText;
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter;
            Text {
                width: root.paddingItem.width - thumbnail.width;
                visible: text != "";
                anchors.verticalCenter: parent.verticalCenter;
                text: model.abstract;
                color: constant.colorMid;
                font: constant.subTitleFont;
                textFormat: Text.PlainText;
                elide: Text.ElideRight;
            }
            Image {
                id: thumbnail;
                asynchronous: true;
                enabled: source != "";
                visible: enabled;
                width: enabled ? constant.thumbnailSize : 0;
                height: width;
                source: picUrl;
                fillMode: Image.PreserveAspectCrop;
                clip: true;
            }
        }
        Text {
            x: constant.paddingLarge;
            text: user_name + "  " + create_time;
            font: constant.subTitleFont;
            color: constant.colorMid;
        }
    }
    Row {
        anchors { right: parent.right; bottom: parent.bottom; margins: constant.paddingMedium; }
        Image {
            asynchronous: true;
            source: "../gfx/btn_icon_comment_n.png";
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter;
            text: post_num;
            font: constant.subTitleFont;
            color: constant.colorMid
        }
    }
}
