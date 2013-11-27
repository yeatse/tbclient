import QtQuick 1.1

Flipable {
    id: root;

    implicitHeight: constant.graphicSizeLarge*2;
    width: screen.width;
    height: visible ? implicitHeight : 0;

    front: Item {
        width: root.width; height: root.implicitHeight;
        BorderImage {
            anchors.fill: parent;
            source: privateStyle.imagePath("qtg_fr_list_heading_normal", tbsettings.whiteTheme);
            border { left: 28; top: 5; right: 28; bottom: 0 }
        }
    }

    back: Item {
        width: root.width; height: root.implicitHeight;
        BorderImage {
            anchors.fill: parent;
            source: privateStyle.imagePath("qtg_fr_list_heading_normal", tbsettings.whiteTheme);
            border { left: 28; top: 5; right: 28; bottom: 0 }
        }
    }

    transform: Rotation {
        id: flipRot;
        origin: Qt.vector3d(root.width/2, root.height/2, 0);
        axis: Qt.vector3d(0, 1, 0);
        angle: 0;
    }

    states: State {
        name: "back";
        PropertyChanges {
            target: flipRot; angle: 180;
        }
    }

    transitions: Transition {
        RotationAnimation {
            direction: RotationAnimation.Clockwise;
        }
    }
}
