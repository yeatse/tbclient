import QtQuick 1.1
import com.nokia.symbian 1.1

ContextMenu {
    id: root;

    property variant caller;
    property bool __isClosing: false;

    MenuLayout {
        MenuItem {
            text: qsTr("Launch library");
            onClicked: signalCenter.imageSelected(caller, utility.selectImage(3));
        }
        MenuItem {
            text: qsTr("Select by folder");
            onClicked: signalCenter.imageSelected(caller, utility.selectImage(1));
        }
        MenuItem {
            text: qsTr("Capture a image");
            onClicked: signalCenter.imageSelected(caller, utility.selectImage(2));
        }
        MenuItem {
            text: qsTr("Scribble");
        }
    }

    Component.onCompleted: open();
    onStatusChanged: {
        if (status === DialogStatus.Closing){
            __isClosing = true;
        } else if (status === DialogStatus.Closed && __isClosing){
            root.destroy();
        }
    }
}
