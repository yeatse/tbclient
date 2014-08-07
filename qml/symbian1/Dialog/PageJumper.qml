import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    id: root;

    property int currentPage: 1;
    property int totalPage: 1;

    titleText: qsTr("Jump to page: [1-%1]").arg(totalPage);
    buttonTexts: [qsTr("OK"), qsTr("Cancel")];
    privateCloseIcon: true;

    content: Item {
        id: contentItem;
        width: parent.width;
        height: row.height + constant.paddingLarge*2;
        Row {
            id: row;
            anchors {
                left: parent.left; right: parent.right;
                margins: constant.paddingLarge;
                verticalCenter: parent.verticalCenter;
            }
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
                onTextChanged: root.currentPage = text||1;
                inputMethodHints: Qt.ImhDigitsOnly;
                Keys.onPressed: {
                    if (event.key == Qt.Key_Select
                            ||event.key == Qt.Key_Enter
                            ||event.key == Qt.Key_Return){
                        event.accepted = true;
                        root.accept();
                    }
                }
            }
        }
    }

    onButtonClicked: index === 0 ? accept() : reject();
    onStatusChanged: {
        if (status === DialogStatus.Open){
            textField.forceActiveFocus();
            textField.selectAll();
        }
    }
}
