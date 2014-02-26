import QtQuick 1.1

Item {
    id: delegateItem

    property alias text: itemText.text;
    signal clicked;

    height: 64;
    anchors.left: parent.left
    anchors.right: parent.right

    MouseArea {
        id: delegateMouseArea
        anchors.fill: parent;
        onClicked: {
            accept();
            delegateItem.clicked();
        }
    }


    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: delegateMouseArea.pressed ? "#3D3D3D" : "transparent";
    }

    Text {
        id: itemText
        elide: Text.ElideRight
        color: "white";
        anchors.verticalCenter: delegateItem.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        font.family: "Nokia Pure Text";
        font.pixelSize: 24;
        font.capitalization: Font.MixedCase
        font.bold: true
    }
}
