import QtQuick 1.0

Item {
    id: root;

    property alias text: label.text;

    height: label.paintedHeight + 2*constant.paddingSmall;
    width: Math.max(height, label.paintedWidth + 2*constant.paddingMedium);

    BorderImage {
        anchors.fill: parent;
        source: "../gfx/countbubble.png";
        border { left: 10; right: 10; top: 10; bottom: 10; }
    }

    Text {
        id: label;
        color: platformStyle.colorNormalLight;
        font: constant.subTitleFont;
        anchors.centerIn: parent;
    }
}
