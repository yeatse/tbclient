import QtQuick 1.1
import com.nokia.meego 1.1

Sheet {
    id: root;

    acceptButtonText: qsTr("Save");
    rejectButtonText: qsTr("Cancel");

    onAccepted: tbsettings.signature = textArea.text;

    content: Flickable {
        id: flickable;
        anchors { fill: parent; margins: constant.paddingLarge; }
        contentWidth: width;
        contentHeight: textArea.height;
        onHeightChanged: textArea.setHeight();
        TextArea {
            id: textArea;
            width: parent.width;
            text: tbsettings.signature;
            function setHeight(){
                height = Math.max(implicitHeight, flickable.height);
            }
            onImplicitHeightChanged: setHeight();
        }
    }

    onStatusChanged: {
        if (status === DialogStatus.Open){
            textArea.forceActiveFocus();
            textArea.platformOpenSoftwareInputPanel();
        }
    }
}
