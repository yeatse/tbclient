import QtQuick 1.1

Item {
    id: root;

    property alias paddingItem: paddingItem;

    signal clicked;
    signal pressAndHold;

    implicitWidth: page.width;
    implicitHeight: constant.graphicSizeLarge;

    BorderImage {
        id: background;
        anchors {
            left: parent.left; leftMargin: constant.paddingSmall;
            right: parent.right; rightMargin: constant.paddingSmall;
            top: parent.top; topMargin: constant.paddingSmall;
            bottom: parent.bottom; bottomMargin: constant.paddingSmall;
        }
        border {
            left: 10; top: 10;
            right: 10; bottom: 10;
        }
        source: "../gfx/bg_pb_add_"+(mouseArea.pressed?"s":"n")+constant.invertedString;
        asynchronous: true;
    }

    Item {
        id: paddingItem;
        anchors {
            left: background.left; leftMargin: constant.paddingLarge;
            right: background.right; rightMargin: constant.paddingLarge;
            top: background.top; topMargin: constant.paddingLarge;
            bottom: background.bottom; bottomMargin: constant.paddingLarge;
        }
    }

    MouseArea {
        id: mouseArea;
        anchors.fill: parent;
        onClicked: root.clicked();
        onPressAndHold: root.pressAndHold();
    }
}
