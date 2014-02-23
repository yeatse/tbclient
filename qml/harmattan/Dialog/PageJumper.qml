import QtQuick 1.1
import com.nokia.meego 1.1

Sheet {
    id: root;

    property int currentPage: 1;
    property int totalPage: 1;

    acceptButtonText: qsTr("OK");
    rejectButtonText: qsTr("Cancel");

    content: Column {
        id: contentItem;
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: constant.paddingLarge; }
        spacing: constant.paddingLarge;
        Text {
            font: constant.labelFont;
            color: constant.colorLight;
            text: qsTr("Jump to page: [1-%1]").arg(totalPage);
        }
        Row {
            id: row;
            width: parent.width;
            Slider {
                id: slider;
                width: parent.width - textField.width;
                value: root.currentPage;
                maximumValue: root.totalPage;
                minimumValue: 1;
                stepSize: 1;
                onValueChanged: root.currentPage = value;
            }
            TextField {
                id: textField;
                anchors.verticalCenter: parent.verticalCenter;
                text: root.currentPage;
                validator: IntValidator {
                    bottom: 1; top: root.totalPage;
                }
                platformStyle: TextFieldStyle { defaultWidth: 72; }
                onTextChanged: root.currentPage = text||1;
                inputMethodHints: Qt.ImhDigitsOnly;
            }
        }
    }

    onStatusChanged: {
        if (status == DialogStatus.Open){
            textField.forceActiveFocus();
            textField.platformOpenSoftwareInputPanel();
        }
    }
}
