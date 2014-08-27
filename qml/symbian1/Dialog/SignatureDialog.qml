import QtQuick 1.0
import com.nokia.symbian 1.0
import "../Component"

CustomDialog {
    id: root;

    titleText: qsTr("Signature");
    buttonTexts: [qsTr("Save"), qsTr("Clear"), qsTr("Cancel")];
/*
    buttons: ToolBar {
        id: buttons
        //width: parent.width
        height: privateStyle.toolBarHeightLandscape + 2 * platformStyle.paddingSmall
        tools: Row {
            //id: buttonRow
            anchors.centerIn: parent
            spacing: platformStyle.paddingMedium

            ToolButton {
                //id: acceptButton
                text: qsTr("Save");
                width: (buttons.width - 4 * platformStyle.paddingMedium) / 3
                onClicked: {
                    tbsettings.signature = textArea.text;
                    root.accept();
                }
            }
            ToolButton {
                //id: rejectButton
                width: (buttons.width - 4 * platformStyle.paddingMedium) / 3
                text: qsTr("Clear");
                onClicked: {
                    tbsettings.signature = "";
                    root.accept();
                }
            }
            ToolButton {
                //id: rejectButton
                width: (buttons.width - 4 * platformStyle.paddingMedium) / 3
                text: qsTr("Cancel");
                onClicked: {
                    root.reject();
                }
            }
        }
    }*/
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
            //textArea.openSoftwareInputPanel();
        }
    }
}
