import QtQuick 1.1

Rectangle {
    id: root;

    property alias title: text.text;

    signal clicked;

    implicitWidth: screen.width;
    implicitHeight: visible ? constant.headerHeight : 0;
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
        maximumLineCount: 2;
        elide: Text.ElideRight;
        wrapMode: Text.WrapAnywhere;
    }

    MouseArea {
        id: mouseArea;
        anchors.fill: parent;
        onClicked: root.clicked();
    }
}
