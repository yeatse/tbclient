import QtQuick 1.1
import com.nokia.symbian 1.1
import com.yeatse.tbclient 1.0
import "../../js/Utils.js" as Utils

Item {
    id: root;

    property string audioUrl;
    property int duration;

    property string mode: "zero";   //play, stop
    property string stateString: mouseArea.pressed ? "s" : "n";

    width: parent.width; height: parent.height;

    BorderImage {
        anchors.fill: parent;
        source: privateStyle.imagePath("qtg_fr_list_heading_normal", tbsettings.whiteTheme);
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

    ToolButton {
        id: deleteBtn;
        visible: false;
        anchors { left: icon.right; bottom: icon.bottom; bottomMargin: -constant.paddingMedium; }
        iconSource: "toolbar-delete";
        platformInverted: tbsettings.whiteTheme;
        onClicked: {
            audioWrapper.stop();
            audioUrl = "";
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
            PropertyChanges { target: deleteBtn; visible: true; }
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
