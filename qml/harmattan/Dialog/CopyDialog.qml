import QtQuick 1.1
import com.nokia.meego 1.1

Sheet {
    id: root;

    property alias text: textArea.text;
    property bool __isClosing: false;
    property int __isPage;  //to make sheet happy

    acceptButtonText: qsTr("Copy");
    rejectButtonText: qsTr("Cancel");

    content: Item {
        width: parent.width;
        height: parent.height;
        TextArea {
            id: textArea;
            anchors {
                fill: parent; margins: constant.paddingMedium;
            }
            readOnly: true;
            textFormat: TextEdit.PlainText;
        }
    }

    onStatusChanged: {
        if (status === DialogStatus.Closing){
            __isClosing = true;
        } else if (status === DialogStatus.Closed && __isClosing){
            root.destroy(250);
        } else if (status === DialogStatus.Open){
            textArea.selectAll();
        }
    }

    onAccepted: {
        if (textArea.selectedText === "") textArea.selectAll();
        textArea.copy();
        signalCenter.showMessage(qsTr("Operation completed"))
    }

    Component.onCompleted: open();
}
