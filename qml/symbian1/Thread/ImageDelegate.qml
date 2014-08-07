import QtQuick 1.0

Item {
    id: root;

    height: bheight;

    MouseArea {
        width: bwidth;
        height: parent.height;
        onClicked: signalCenter.viewImage(format);
    }

    Image {
        id: img;
        width: bwidth;
        height: parent.height;
        fillMode: Image.PreserveAspectFit;
        sourceSize.width: bwidth;
        source: text;
        asynchronous: true;
    }

    Image {
        anchors.centerIn: img;
        sourceSize: constant.sizeMedium;
        source: img.status === Image.Ready ? "" : "../gfx/photos.svg";
        asynchronous: true;
    }
}
