import QtQuick 1.1
import com.nokia.meego 1.1
import "../Component"

AbstractDialog {
    id: root;

    property variant caller;
    property bool __isClosing: false;

    titleText: "选择图片"

    contentList: [
        DialogItem {
            text: qsTr("Launch library");
            onClicked: signalCenter.selectImage(caller);
        },
        DialogItem {
            text: qsTr("Capture a image");
            onClicked: utility.selectImage(2);
        },
        DialogItem {
            text: qsTr("Scribble");
            onClicked: pageStack.push(Qt.resolvedUrl("ScribblePage.qml"), {caller: caller});
        }
    ]

    Component.onCompleted: open();
    onStatusChanged: {
        if (status === DialogStatus.Closing){
            __isClosing = true;
        } else if (status === DialogStatus.Closed && __isClosing){
            root.destroy(250);
        }
    }
}
