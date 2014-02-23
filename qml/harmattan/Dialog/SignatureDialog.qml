import QtQuick 1.1
import com.nokia.meego 1.1

CommonDialog {
    id: root;

    titleText: qsTr("Signature");
    buttonTexts: [qsTr("Save"), qsTr("Clear"), qsTr("Cancel")];

    content: Item {
        width: platformContentMaximumWidth;
        height: Math.min(platformContentMaximumHeight, 180);
        TextArea {
            id: textArea;
            anchors {
                fill: parent; margins: constant.paddingMedium;
            }
            text: tbsettings.signature;
        }
    }

    onButtonClicked: {
        switch (index){
        case 0:
            tbsettings.signature = textArea.text;
            root.accept();
            break;
        case 1:
            tbsettings.signature = "";
            root.accept();
            break;
        default:
            root.reject();
            break;
        }
    }

    onStatusChanged: {
        if (status === DialogStatus.Open){
            textArea.forceActiveFocus();
            textArea.openSoftwareInputPanel();
        }
    }
}
