import QtQuick 1.1

Item {
    id: root;

    property variant post;

    width: screen.width;
    height: contentCol.height + constant.paddingLarge*2;

    Image {
        id: avatar;
        anchors {
            left: root.left; top: root.top;
            margins: constant.paddingLarge;
        }
        width: constant.graphicSizeMedium;
        height: constant.graphicSizeMedium;
        sourceSize: constant.sizeMedium;
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
        Text {
            width: parent.width;
            wrapMode: Text.WrapAnywhere;
        }
    }
}
