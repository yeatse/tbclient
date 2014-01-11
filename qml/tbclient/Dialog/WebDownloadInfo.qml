import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    id: downloadingIndicator;

    property alias info: indicatorText.text;

    titleText: qsTr("Downloading...");
    content: Item {
        width: downloadingIndicator.platformContentMaximumWidth;
        height: indicatorColumn.height + constant.paddingLarge*2;
        Column {
            id: indicatorColumn;
            anchors.centerIn: parent;
            spacing: constant.paddingMedium;
            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter;
                width: constant.graphicSizeLarge;
                height: constant.graphicSizeLarge;
                running: true;
            }
            Text {
                id: indicatorText;
                anchors.horizontalCenter: parent.horizontalCenter;
                font: constant.labelFont;
                color: "white";
                text: " ";
            }
        }
    }
    buttonTexts: [qsTr("Cancel")];
    onButtonClicked: webView.abortDownload();
}
