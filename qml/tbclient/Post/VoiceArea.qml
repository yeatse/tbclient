import QtQuick 1.1

Item {
    id: root;

    property string mode: "zero";
    property string stateString: mouseArea.pressed ? "s" : "n";

    width: parent.width; height: parent.height;

    BorderImage {
        anchors.fill: parent;
        source: privateStyle.imagePath("qtg_fr_list_heading_normal", tbsettings.whiteTheme);
        border { left: 28; top: 5; right: 28; bottom: 0 }
    }

    Image {
        id: icon;
        anchors.centerIn: parent;
        width: constant.thumbnailSize;
        height: constant.thumbnailSize;
        sourceSize: Qt.size(width, height);
        source: "../../gfx/but_posts_record_%1_%2.png".arg(mode).arg(stateString);
    }

    MouseArea {
        id: mouseArea;
        anchors.fill: icon;
    }
}
