import QtQuick 1.0
import com.nokia.symbian 1.0
import "../Component"

CustomDialog {
    id: root;

    titleText: qsTr("Remind settings");
    buttonTexts: [qsTr("OK")];
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
                // Different widths for 1 and 2 button cases
                text: qsTr("OK");
                width: (buttons.width - 3 * platformStyle.paddingMedium) / 2
                //onClicked: accept();
            }
        }
    }*/
    QtObject {
        id: internal;
        function getValue(){
            switch (tbsettings.remindInterval){
            case 0: return 0;
            case 1: return 1;
            case 2: return 2;
            case 5: return 3;
            default: return 4;
            }
        }
        function getValueText(){
            switch (slider.value){
            case 0: return qsTr("Disabled");
            case 1: return qsTr("%n min(s)", "", 1);
            case 2: return qsTr("%n min(s)", "", 2);
            case 3: return qsTr("%n min(s)", "", 5);
            default: return qsTr("%n min(s)", "", 30);
            }
        }
        function setValue(){
            switch (slider.value){
            case 0: return 0;
            case 1: return 1;
            case 2: return 2;
            case 3: return 5;
            default: return 30;
            }
        }
    }

    content: Item {
        width: platformContentMaximumWidth;
        height: Math.min(platformContentMaximumHeight, contentCol.height);

        Flickable {
            id: flickable;
            anchors.fill: parent;
            clip: true;
            contentWidth: parent.width;
            contentHeight: contentCol.height;
            Column {
                id: contentCol;
                anchors { left: parent.left; right: parent.right; margins: platformStyle.paddingLarge; }
                spacing: platformStyle.paddingMedium;
                Item { width: 1; height: 1; }
                ListItemText {
                    text: qsTr("Remind interval");
                }
                Slider {
                    id: slider;
                    width: parent.width;
                    minimumValue: 0;
                    maximumValue: 4;
                    stepSize: 1;
                    value: internal.getValue();
                    valueIndicatorVisible: true;
                    valueIndicatorText: internal.getValueText();
                    onPressedChanged: {
                        if (!pressed){
                            tbsettings.remindInterval = internal.setValue();
                        }
                    }
                }
                ListItemText {
                    text: qsTr("Remind contents");
                }
                Repeater {
                    model: [
                        [qsTr("Remind at background"),"remindBackground"],
                        [qsTr("New fans"),"remindFans"],
                        [qsTr("Private letters"),"remindPletter"],
                        [qsTr("Bookmark updates"),"remindBookmark"],
                        [qsTr("Reply me"),"remindReplyme"],
                        [qsTr("Mentions"),"remindAtme"]
                    ]
                    CheckBox {
                        checked: tbsettings[modelData[1]];
                        text: modelData[0];
                        onClicked: tbsettings[modelData[1]] = checked;
                    }
                }
            }
        }
    }
}
