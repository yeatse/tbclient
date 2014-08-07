import QtQuick 1.0
import com.nokia.symbian 1.0

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
    //buttonTexts: [qsTr("Cancel")];
    //onButtonClicked: webView.abortDownload();

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
                text: qsTr("Cancel");
                width: (buttons.width - 3 * platformStyle.paddingMedium) / 2
                onClicked: webView.abortDownload();
            }
        }
    }
}
