import QtQuick 1.0

Item {
    id: root;

    property string iconName;
    property string title;
    property string subTitle;
    property bool markVisible: false;

    signal clicked;

    width: parent.width / 3;
    height: 120;
    opacity: mouseArea.pressed ? 0.7 : 1;

    BorderImage {
        anchors.fill: parent;
        source: "../gfx/btn_managebg.png"
        border { left: 5; right: 5; top: 5; bottom: 5; }
    }

    Column {
        id: logo;
        anchors.centerIn: parent;
        Image {
            anchors.horizontalCenter: parent.horizontalCenter;
            source: "../gfx/cent_icon_"+root.iconName+".png"
            Image {
                anchors { top: parent.top; right: parent.right; }
                source: root.markVisible ? "../gfx/ico_mbar_news_point.png" : "";
            }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter;
            font: constant.subTitleFont;
            color: constant.colorLight;
            text: root.title;
        }
    }
    Text {
        anchors { top: logo.bottom; horizontalCenter: parent.horizontalCenter; }
        font.family: "Series 60 ZDigi";
        font.pixelSize: constant.fontXSmall;
        color: constant.colorMid;
        text: root.subTitle;
    }

    MouseArea {
        id: mouseArea;
        anchors.fill: parent;
        onClicked: root.clicked();
    }
}
