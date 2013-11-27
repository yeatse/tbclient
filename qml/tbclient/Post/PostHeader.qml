import QtQuick 1.1

Rectangle {
    id: root;

    property alias text: text.text;

    width: screen.width;
    height: visible ? constant.headerHeight : 0;
    z: 10;
    color: "black";

    BorderImage {
        anchors.fill: parent;
        source: "../../gfx/sheet_header"+constant.invertedString+".png"
        border { left: 20; right: 20; top: 20; bottom: 20; }
    }

    Text {
        id: text;
        anchors {
            left: parent.left; right: parent.right;
            margins: constant.paddingXLarge;
            verticalCenter: parent.verticalCenter;
        }
        font.pixelSize: constant.fontXLarge;
        color: constant.colorLight;
        style: Text.Raised;
        styleColor: platformStyle.colorNormalMid;
        maximumLineCount: 2;
        elide: Text.ElideRight;
        wrapMode: Text.WrapAnywhere;
    }
}
