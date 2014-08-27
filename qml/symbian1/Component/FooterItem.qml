import QtQuick 1.0
import com.nokia.symbian 1.0

Item {
    id: root;

    property alias text: button.text;
    signal clicked;

    width: screen.width;
    height: visible ? constant.graphicSizeLarge : 0;

    Button {
        id: button;
        anchors {
            left: parent.left; right: parent.right; margins: constant.paddingLarge;
            verticalCenter: parent.verticalCenter;
        }
        //platformInverted: tbsettings.whiteTheme;
        text: qsTr("Load More");
        onClicked: root.clicked();
    }
}
