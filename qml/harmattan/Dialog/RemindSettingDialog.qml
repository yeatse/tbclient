import QtQuick 1.1
import com.nokia.meego 1.1

Sheet {
    id: root;

    title: Text {
        font.pixelSize: constant.fontXXLarge;
        color: constant.colorLight;
        anchors { left: parent.left; leftMargin: constant.paddingXLarge; verticalCenter: parent.verticalCenter; }
        text: qsTr("Remind settings");
    }

    acceptButtonText: qsTr("OK");

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
        function getValueText(v){
            switch (v){
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

    content: Flickable {
        id: flickable;
        anchors.fill: parent;
        clip: true;
        contentWidth: width;
        contentHeight: contentCol.height + constant.paddingLarge*2;
        Column {
            id: contentCol;
            anchors {
                left: parent.left; right: parent.right; top: parent.top;
                margins: constant.paddingLarge;
            }
            spacing: constant.paddingMedium;
            Text {
                font: constant.labelFont;
                color: constant.colorMid;
                text: qsTr("Remind interval");
            }
            Slider {
                id: slider;
                width: parent.width;
                minimumValue: 0;
                maximumValue: 4;
                stepSize: 1;
                value: internal.getValue();
                function formatValue(v){
                    return internal.getValueText(v);
                }
                valueIndicatorVisible: true;
                onPressedChanged: {
                    if (!pressed){
                        tbsettings.remindInterval = internal.setValue();
                    }
                }
            }
            Text {
                font: constant.labelFont;
                color: constant.colorMid;
                text: qsTr("Remind interval");
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
