import QtQuick 1.0
import com.nokia.symbian 1.0
import com.yeatse.tbclient 1.0
import "../../js/Utils.js" as Utils
import "../Component"

Item {
    id: root;

    property string audioUrl;
    property int duration;

    property string mode: "zero";   //play, stop
    property string stateString: mouseArea.pressed ? "s" : "n";

    width: parent.width; height: parent.height;

    BorderImage {
        anchors.fill: parent;
        source: privateStyle.imagePath("qtg_fr_list_heading_normal");
        border { left: 28; top: 5; right: 28; bottom: 0 }
    }

    Image {
        id: icon;
        anchors.centerIn: parent;
        width: constant.thumbnailSize;
        height: constant.thumbnailSize;
        sourceSize: Qt.size(width, height);
        source: "../gfx/but_posts_record_%1_%2.png".arg(mode).arg(stateString);
    }

    ToolButtonWithTip {
        id: volumeBtn;
        toolTipText: "音量";
        anchors { right: icon.left; bottom: icon.bottom; bottomMargin: -constant.paddingMedium; }
        iconSource: "../gfx/volume.svg";
        //platformInverted: tbsettings.whiteTheme;
        onClicked: {
            volumeSelector.open();
        }
    }
    ToolButtonWithTip {
        id: deleteBtn;
        enabled: false;
        toolTipText: "删除";
        anchors { left: icon.right; bottom: icon.bottom; bottomMargin: -constant.paddingMedium; }
        iconSource: "toolbar-delete";
        //platformInverted: tbsettings.whiteTheme;
        onClicked: {
            audioWrapper.stop();
            audioUrl = "";
        }
    }
    CustomDialog {
        id: volumeSelector

        //titleText: qsTr("Select pen width(selected: %1)").arg(slider.value);
        titleText: "调节音量";
        buttonTexts: ["确定", "取消"];

        onButtonClicked: if (index === 0) accept();
        onAccepted: tbsettings.volumeLevel = slider.value;
        content: Slider {
            id: slider
            anchors {
                left: parent.left;
                right: parent.right;
                margins: constant.paddingLarge
                verticalCenter: parent.verticalCenter
            }
            valueIndicatorVisible: true;
            minimumValue: 0
            maximumValue: 10
            stepSize: 1
            value: tbsettings.volumeLevel
            Keys.onPressed: {
                if (event.key == Qt.Key_Select
                        ||event.key == Qt.Key_Enter
                        ||event.key == Qt.Key_Return){
                    widthSelector.accept();
                    event.accepted = true;
                } else if (event.key == Qt.Key_Backspace){
                    widthSelector.reject();
                    event.accepted = true;
                }
            }
        }
        onStatusChanged: {
            if (status === DialogStatus.Open){
                slider.forceActiveFocus();
            }
        }
    }

    MouseArea {
        id: mouseArea;
        anchors.fill: icon;
        onPressAndHold: {
            recorder.record();
        }
        onReleased: {
            duration = recorder.duration;
            recorder.stop();
            if (duration > 1000){
                audioUrl = recorder.outputLocation;
            } else {
                signalCenter.showMessage(qsTr("Audio is too short to send out"));
            }
        }
    }

    Text {
        id: timeLabel;
        property int time: recorder.duration;
        anchors {
            top: parent.top; topMargin: constant.paddingMedium;
            horizontalCenter: parent.horizontalCenter;
        }
        font: constant.labelFont;
        color: constant.colorLight;
        text: Utils.milliSecondsToString(time);
        visible: recorder.state === AudioRecorder.RecordingState;
    }
    Text {
        id: infoLabel;
        anchors {
            bottom: parent.bottom; bottomMargin: constant.paddingMedium;
            horizontalCenter: parent.horizontalCenter;
        }
        font: constant.labelFont;
        color: constant.colorLight;
        text: recorder.state === AudioRecorder.RecordingState ? qsTr("Release to finish recording")
                                                              : qsTr("Long press to start recording");
    }
    states: [
        State {
            name: "Playback";
            PropertyChanges { target: root; mode: audioWrapper.playing ? "stop" : "play"; }
            PropertyChanges { target: deleteBtn; enabled: true; }
            PropertyChanges {
                target: mouseArea;
                onPressAndHold: {}
                onReleased: {}
                onClicked: {
                    if (audioWrapper.playing){
                        audioWrapper.stop();
                    } else {
                        audioWrapper.currentMd5 = "";
                        audioWrapper.changeFile("file:///"+audioUrl)
                    }
                }
            }
            PropertyChanges {
                target: timeLabel;
                time: audioWrapper.playing ? audioWrapper.position : duration;
                visible: true;
            }
            PropertyChanges {
                target: infoLabel;
                text: audioWrapper.playing ? qsTr("Click to stop playback") : qsTr("Click to start playback");
            }
            when: root.audioUrl !== "";
        }
    ]
}
