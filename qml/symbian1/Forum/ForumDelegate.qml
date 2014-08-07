import QtQuick 1.1
import "../Component"

AbstractItem {
    id: root;

    implicitHeight: contentCol.height + constant.paddingLarge*2;
    onClicked: {
        var prop = { threadId: id, title: title };
        signalCenter.enterThread(prop);
    }

    Column {
        id: contentCol;
        anchors {
            left: root.paddingItem.left;
            right: root.paddingItem.right;
            top: root.paddingItem.top;
        }
        spacing: constant.paddingSmall;
        Item {
            width: parent.width;
            height: childrenRect.height;
            Text {
                font: constant.subTitleFont;
                color: constant.colorMid;
                text: author;
            }
            Row {
                anchors.right: parent.right;
                spacing: 2;
                Image {
                    asynchronous: true;
                    enabled: is_good;
                    visible: enabled;
                    source: enabled ? "../gfx/icon_elite"+constant.invertedString+".png" : "";
                }
                Image {
                    asynchronous: true;
                    enabled: is_top;
                    visible: enabled;
                    source: enabled ? "../gfx/icon_top"+constant.invertedString+".png" : "";
                }
            }
        }
        Text {
            width: parent.width;
            text: title;
            color: constant.colorLight;
            font: constant.titleFont;
            wrapMode: Text.WrapAnywhere;
            textFormat: Text.PlainText;
        }
        Row {
            visible: tbsettings.showAbstract;
            anchors.horizontalCenter: parent.horizontalCenter;
            Text {
                width: contentCol.width - thumbnail.width;
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
            text: reply_show;
            font: constant.subTitleFont;
            color: constant.colorMid
        }
    }
    Row {
        anchors { right: parent.right; bottom: parent.bottom; margins: constant.paddingSmall; }
        Image {
            asynchronous: true;
            source: "../gfx/btn_icon_comment_n"+constant.invertedString+".png";
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter;
            text: reply_num;
            font: constant.subTitleFont;
            color: constant.colorMid
        }
    }
}
