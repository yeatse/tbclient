import QtQuick 1.1
import com.nokia.meego 1.1

Rectangle {
    id: root;

    property alias title: text.text;
    property bool loadingVisible: page.loading;

    signal clicked;

    implicitWidth: page.width;
    implicitHeight: visible ? constant.headerHeight : 0;
    color: "#1f2837";
    z: 10;

    Rectangle {
        id: mask;
        anchors.fill: parent;
        color: "black";
        opacity: mouseArea.pressed ? 0.3 : 0;
    }

    Text {
        id: text;
        anchors {
            left: parent.left; right: parent.right;
            margins: constant.paddingXLarge;
            verticalCenter: parent.verticalCenter;
        }
        font.pixelSize: constant.fontXXLarge;
        color: "white";
        style: Text.Raised;
        styleColor: "#8c8c8c";
        maximumLineCount: 2;
        elide: Text.ElideRight;
        wrapMode: Text.WrapAnywhere;
    }

    BusyIndicator {
        anchors {
            right: parent.right; rightMargin: constant.paddingXLarge;
            verticalCenter: parent.verticalCenter;
        }
        platformStyle: BusyIndicatorStyle {
            size: "small";
            inverted: true;
        }
        running: true;
        visible: root.loadingVisible;
    }

    MouseArea {
        id: mouseArea;
        anchors.fill: parent;
        onClicked: root.clicked();
    }
}
