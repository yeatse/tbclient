import QtQuick 1.1

Item {
    id: root;

    implicitHeight: bheight;

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
        source: img.status === Image.Ready ? "" : "../gfx/image_default"+constant.invertedString;
        asynchronous: true;
    }
}
