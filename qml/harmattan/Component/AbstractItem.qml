import QtQuick 1.1
import com.nokia.meego 1.1

Item {
    id: root;

    property alias paddingItem: paddingItem;

    signal clicked;
    signal pressAndHold;

    implicitWidth: page.width;
    implicitHeight: constant.graphicSizeLarge;

    opacity: mouseArea.pressed ? 0.7 : 1;

    Item {
        id: paddingItem;
        anchors {
            left: parent.left; leftMargin: constant.paddingLarge;
            right: parent.right; rightMargin: constant.paddingLarge;
            top: parent.top; topMargin: constant.paddingLarge;
            bottom: parent.bottom; bottomMargin: constant.paddingLarge;
        }
    }

    Rectangle {
        id: bottomLine;
        anchors {
            left: root.left; right: root.right; bottom: parent.bottom;
        }
        height: 1;
        color: constant.colorMarginLine;
    }

    MouseArea {
        id: mouseArea;
        anchors.fill: parent;
        enabled: root.enabled;
        onClicked: {
            if (root.ListView.view)
                root.ListView.view.currentIndex = index;
            root.clicked();
        }
        onPressAndHold: {
            root.pressAndHold();
        }
    }

    NumberAnimation {
        id: onAddAnimation
        target: root
        property: "opacity"
        duration: 250
        from: 0.25; to: 1;
    }

    ListView.onAdd: {
        onAddAnimation.start();
    }
}
