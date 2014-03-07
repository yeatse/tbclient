import QtQuick 1.1
import "../Component"

AbstractDelegate {
    id: root;
    implicitHeight: contentCol.height + 32;
    onClicked: {
        var prop = { threadId: thread_id, title: title };
        signalCenter.enterThread(prop);
    }
    Column {
        id: contentCol;
        anchors {
            left: parent.left; right: parent.right;
            top: parent.top; margins: constant.paddingSmall+4;
        }
        spacing: constant.paddingSmall;
        Item {
            width: parent.width;
            height: feedLabel.height;
            BorderImage {
                id: feedLabel;
                asynchronous: true;
                source: "../gfx/bg_forum_feed_label"+constant.invertedString;
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
                spacing: 4;
                Image {
                    asynchronous: true;
                    enabled: is_good;
                    visible: enabled;
                    source: enabled ? "../gfx/icon_elite"+constant.invertedString : "";
                }
                Image {
                    asynchronous: true;
                    enabled: is_top;
                    visible: enabled;
                    source: enabled ? "../gfx/icon_top"+constant.invertedString : "";
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
                wrapMode: Text.WrapAnywhere;
                textFormat: Text.PlainText;
                elide: Text.ElideRight;
                maximumLineCount: thumbnail.enabled ? 2 : 1;
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
        anchors { right: parent.right; bottom: parent.bottom; margins: 12 }
        Image {
            asynchronous: true;
            source: "../gfx/btn_icon_comment_n"+constant.invertedString;
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter;
            text: post_num;
            font: constant.subTitleFont;
            color: constant.colorMid
        }
    }
}
