import QtQuick 1.1

Item {
    id: root;

    property alias iconSource: icon.source;
    property string title;
    signal clicked;

    height: itemCol.height + constant.paddingLarge*2;

    Column {
        id: itemCol;
        anchors.centerIn: parent;
        spacing: constant.paddingSmall;
        Image {
            id: icon;
            anchors.horizontalCenter: parent.horizontalCenter;
            width: constant.graphicSizeLarge;
            height: constant.graphicSizeLarge;
            sourceSize: Qt.size(width, height);
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter;
            font: constant.subTitleFont;
            text: root.title;
            color: platformStyle.colorNormalLight;
        }
    }
    Rectangle {
        anchors.fill: parent;
        color: "black";
        opacity: mouseArea.pressed ? 0.5 : 0;
    }
    MouseArea {
        id: mouseArea;
        anchors.fill: parent;
        onClicked: root.clicked();
    }
}
