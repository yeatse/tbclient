import QtQuick 1.0

Rectangle {
    id: root;

    property alias title: text.text;

    signal clicked;

    width: screen.width;
    height: visible ? constant.headerHeight : 0;
    color: "#1080dd";
    z: 10;

    Rectangle {
        id: mask;
        anchors.fill: parent;
        color: "black";
        opacity: mouseArea.pressed ? 0.3 : 0;
    }

    Image {
        anchors { left: parent.left; top: parent.top; }
        source: "../gfx/meegoTLCorner.png";
    }
    Image {
        anchors { right: parent.right; top: parent.top; }
        source: "../gfx/meegoTRCorner.png";
    }

    Text {
        id: text;
        anchors {
            left: parent.left; right: parent.right;
            margins: constant.paddingXLarge;
            verticalCenter: parent.verticalCenter;
        }
        font.pixelSize: constant.fontXLarge;
        color: "white";
        style: Text.Raised;
        styleColor: platformStyle.colorNormalMid;
        elide: Text.ElideRight;
    }

    MouseArea {
        id: mouseArea;
        anchors.fill: parent;
        onClicked: root.clicked();
    }
}
