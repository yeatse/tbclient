import QtQuick 1.0
import com.nokia.symbian 1.0

TextField {
    id: root;

    signal typeStopped;
    signal cleared;

    onTextChanged: {
        inputTimer.restart();
    }

    platformLeftMargin: searchIcon.width + platformStyle.paddingMedium;
    platformRightMargin: clearButton.width + platformStyle.paddingMedium;

    Timer {
        id: inputTimer;
        interval: 500;
        onTriggered: root.typeStopped();
    }

    Image {
        id: searchIcon;
        anchors { left: parent.left; leftMargin: platformStyle.paddingMedium; verticalCenter: parent.verticalCenter; }
        height: platformStyle.graphicSizeSmall;
        width: platformStyle.graphicSizeSmall;
        sourceSize: Qt.size(platformStyle.graphicSizeSmall, platformStyle.graphicSizeSmall);
        source: privateStyle.toolBarIconPath("toolbar-search", true);
    }

    Item {
        id: clearButton;
        anchors { right: parent.right; rightMargin: platformStyle.paddingMedium; verticalCenter: parent.verticalCenter; }
        height: platformStyle.graphicSizeSmall;
        width: platformStyle.graphicSizeSmall;
        opacity: root.activeFocus ? 1 : 0;
        Behavior on opacity {
            NumberAnimation { duration: 100; }
        }
        Image {
            anchors.fill: parent;
            sourceSize: Qt.size(platformStyle.graphicSizeSmall, platformStyle.graphicSizeSmall);
            //source: privateStyle.imagePath(clearMouseArea.pressed?"qtg_graf_textfield_clear_pressed":"qtg_graf_textfield_clear_normal", root.platformInverted);
            source: privateStyle.imagePath(clearMouseArea.pressed?"qtg_graf_textfield_clear_pressed":"qtg_graf_textfield_clear_normal", false);
        }
        MouseArea {
            id: clearMouseArea;
            anchors.fill: parent;
            onClicked: {
                //root.closeSoftwareInputPanel();
                root.text = "";
                root.parent.forceActiveFocus();
                root.cleared();
            }
        }
    }
}
