import QtQuick 1.1
import com.nokia.meego 1.1

TextField {
    id: root;

    signal typeStopped;
    signal cleared;

    onTextChanged: {
        inputTimer.restart();
    }

    platformStyle: TextFieldStyle {
        paddingLeft: searchIcon.width + constant.paddingMedium;
        paddingRight: clearButton.width + constant.paddingMedium;
    }

    Timer {
        id: inputTimer;
        interval: 500;
        onTriggered: root.typeStopped();
    }

    Image {
        id: searchIcon;
        anchors { left: parent.left; leftMargin: constant.paddingMedium; verticalCenter: parent.verticalCenter; }
        source: "image://theme/icon-m-common-search";
    }

    Item {
        id: clearButton;
        anchors { right: parent.right; rightMargin: constant.paddingMedium; verticalCenter: parent.verticalCenter; }
        height: clearButtonImage.height;
        width: clearButtonImage.width;
        opacity: root.activeFocus ? 1 : 0;
        Behavior on opacity {
            NumberAnimation { duration: 100; }
        }
        Image {
            id: clearButtonImage;
            source: "image://theme/icon-m-input-clear";
        }
        MouseArea {
            id: clearMouseArea;
            anchors.fill: parent;
            onClicked: {
                root.platformCloseSoftwareInputPanel();
                root.text = "";
                root.parent.forceActiveFocus();
                root.cleared();
            }
        }
    }
}
