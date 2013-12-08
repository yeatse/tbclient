import QtQuick 1.1

Item {
    id: root;

    implicitHeight: bheight;

    MouseArea {
        width: bwidth;
        height: parent.height;
        onClicked: {
            console.log(format);
        }
    }

    Image {
        id: img;
        width: bwidth;
        height: parent.height;
        fillMode: Image.PreserveAspectFit;
        sourceSize.width: bwidth;
        source: text;
    }

    Image {
        anchors.centerIn: img;
        sourceSize: constant.sizeMedium;
        source: img.status === Image.Ready
                ? "" : "../../gfx/photos.svg";
    }
}
