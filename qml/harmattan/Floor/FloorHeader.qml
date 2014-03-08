import QtQuick 1.1
import "../../js/main.js" as Script

Item {
    id: root;

    property variant post;

    width: page.width;
    height: contentCol.height + constant.paddingLarge*2;

    BorderImage {
        anchors.fill: parent;
        border.bottom: 10;
        source: "../gfx/bg_grade_up"+constant.invertedString;
    }

    Image {
        id: avatar;
        anchors {
            left: root.left; top: root.top;
            margins: constant.paddingLarge;
        }
        asynchronous: true;
        width: constant.graphicSizeMedium;
        height: constant.graphicSizeMedium;
        sourceSize: constant.sizeMedium;
        source: Script.getPortrait(tbsettings.showImage?post.author.portrait:"");
    }

    Column {
        id: contentCol;
        anchors {
            left: avatar.right; top: parent.top; right: parent.right;
            margins: constant.paddingLarge;
        }
        spacing: constant.paddingMedium;
        Text {
            font: constant.subTitleFont;
            color: constant.colorMid;
            text: {
                var author = post.author;
                var name = author.name;
                if (author.is_like === "1"){
                    name += "  "+qsTr("Lv.%1").arg(author.level_id);
                }
                return name;
            }
        }
        MouseArea {
            id: contentMouseArea;
            width: parent.width;
            height: Math.min(contentLabel.height, constant.graphicSizeLarge+20);
            onHeightChanged: view.positionViewAtBeginning();
            clip: true;
            onClicked: state = state === "" ? "Expanded" : "";
            states: [
                State {
                    name: "Expanded";
                    PropertyChanges {
                        target: contentMouseArea; height: contentLabel.height;
                    }
                }
            ]
            transitions: [
                Transition {
                    PropertyAnimation { property: "height"; }
                }

            ]
            Text {
                id: contentLabel;
                width: parent.width;
                wrapMode: Text.WrapAnywhere;
                font.pixelSize: tbsettings.fontSize;
                color: constant.colorLight;
                text: Script.BaiduParser.__parseFloorContent(post.content)[0];
            }
        }
        Item {
            width: parent.width; height: childrenRect.height;
            Text {
                font: constant.subTitleFont;
                color: constant.colorMid;
                text: Qt.formatDateTime(new Date(Number(post.time+"000")), "yyyy-MM-dd hh:mm:ss");
            }
            Row {
                anchors.right: parent.right;
                Image {
                    asynchronous: true;
                    source: "../gfx/btn_icon_comment_n"+constant.invertedString;
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter;
                    text: internal.totalCount+"";
                    font: constant.subTitleFont;
                    color: constant.colorMid;
                }
            }
        }
    }
}
