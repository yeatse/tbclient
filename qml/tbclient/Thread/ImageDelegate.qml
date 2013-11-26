import QtQuick 1.1
import "../../js/Utils.js" as Util

Item {
    id: root;

    implicitHeight: bheight;

    MouseArea {
        width: bwidth;
        height: parent.height;
        onClicked: {
            console.log(text);
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

    Component.onCompleted: img.source = Util.getThumbnail(text);
}
