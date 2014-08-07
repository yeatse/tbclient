import QtQuick 1.0
import com.nokia.symbian 1.0

CommonDialog {
    id: root;

    property alias text: textArea.text;
    property bool __isClosing: false;

    titleText: qsTr("Copy to clipboard");

    content: Item {
        width: parent.width;
        height: platformContentMaximumHeight;
        TextArea {
            id: textArea;
            anchors {
                fill: parent; margins: constant.paddingMedium;
            }
            readOnly: true;
            textFormat: TextEdit.PlainText;
        }
    }

    //buttonTexts: [qsTr("Copy"), qsTr("Cancel")];

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
                // Different widths for 1 and 2 button cases
                text: qsTr("Copy");
                width: (buttons.width - 3 * platformStyle.paddingMedium) / 2
                onClicked: accept();
            }
            ToolButton {
                //id: rejectButton
                width: (buttons.width - 3 * platformStyle.paddingMedium) / 2
                text: qsTr("Cancel");
                onClicked: reject();
            }
        }
    }
    //onButtonClicked: if (index === 0) accept();

    onStatusChanged: {
        if (status === DialogStatus.Closing){
            __isClosing = true;
        } else if (status === DialogStatus.Closed && __isClosing){
            root.destroy();
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
