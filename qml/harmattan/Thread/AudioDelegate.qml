import QtQuick 1.1
import "../../js/Utils.js" as Utils

Item {
    id: root;
    height: constant.graphicSizeMedium;

    property bool isLoading: text===audioWrapper.currentMd5 && audioWrapper.loading;
    property bool isPlaying: text===audioWrapper.currentMd5 && audioWrapper.playing;

    BorderImage {
        id: icon;
        property string stateString: mouseArea.pressed ? "s" : "d";
        anchors.horizontalCenter: parent.horizontalCenter;
        height: parent.height;
        width: root.width / 2;
        border { left: 20; top: 20; right: 20; bottom: 20; }
        asynchronous: true;
        source: "../gfx/btn_frs_video_"+stateString+constant.invertedString;
    }

    Image {
        anchors {
            left: icon.left; leftMargin: constant.paddingLarge;
            verticalCenter: parent.verticalCenter;
        }
        asynchronous: true;
        source: "../gfx/icon_thread_voice"+constant.invertedString;
    }

    Text {
        anchors {
            right: icon.right; rightMargin: constant.paddingLarge*2;
            verticalCenter: parent.verticalCenter;
        }
        text: Utils.milliSecondsToString(isPlaying?audioWrapper.position:format);
        font: constant.titleFont;
        color: isLoading ? constant.colorMid : constant.colorLight;
    }

    MouseArea {
        id: mouseArea;
        anchors.fill: icon;
        enabled: !isLoading;
        onClicked: audioWrapper.playAudio(text);
    }
}
