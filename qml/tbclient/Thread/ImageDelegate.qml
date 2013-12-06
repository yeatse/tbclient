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
        opacity: 0;
        fillMode: Image.PreserveAspectFit;
        Behavior on opacity {
            NumberAnimation { duration: 250; }
        }
        sourceSize.width: bwidth;
        source: text;
        onStatusChanged: {
            if (status == Image.Ready){
                opacity = 1;
            }
        }
    }

    Image {
        anchors.centerIn: img;
        sourceSize: constant.sizeMedium;
        source: img.status === Image.Ready
                ? "" : "../../gfx/photos.svg";
    }
}
