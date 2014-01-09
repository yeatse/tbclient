import QtQuick 1.1

Item {
    id: root;

    property string title;
    signal clicked;

    Column {
        id: itemCol;
        anchors.centerIn: parent;
        spacing: constant.paddingSmall;
        Image {
            anchors.horizontalCenter: parent.horizontalCenter;
            width: constant.graphicSizeLarge;
            height: constant.graphicSizeLarge;
            sourceSize: Qt.size(width, height);
            source: "../../gfx/more_"+index+".jpg";
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter;
            font: constant.subTitleFont;
            text: root.title;
            color: constant.colorLight;
        }
    }
    Rectangle {
        anchors.fill: parent;
        color: constant.whiteTheme ? "white" : "black";
        opacity: mouseArea.pressed ? 0.5 : 0;
    }
    MouseArea {
        id: mouseArea;
        anchors.fill: parent;
        onClicked: root.clicked();
    }
}
