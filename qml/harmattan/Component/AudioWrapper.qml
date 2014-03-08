import QtQuick 1.1
import QtMultimediaKit 1.1
import "../../js/Utils.js" as Utils

Item {
    id: root;

    // public api:
    property string currentMd5;
    property real volume: audio.volume;
    property int position: audio.position;
    property bool playing: audio.playing;
    property bool loading: audio.status == Audio.Loading;

    function changeFile(filename){
        audio.stop();
        if (audio.status != Audio.Loading){
            audio.source = filename;
            audio.play();
        }
    }

    function playAudio(md5){
        if (audio.status === Audio.Loading){
            coldDown.pendingMd5 = md5;
            coldDown.target = audio;
        } else {
            if (currentMd5 === md5){
                if (audio.playing && !audio.paused){
                    audio.pause();
                } else {
                    audio.play();
                }
            } else {
                currentMd5 = md5;
                audio.stop();
                audio.source = Utils.getAudioUrl(md5);
                audio.play();
            }
        }
    }

    function stop(){
        audio.stop();
    }

    visible: false;

    Audio {
        id: audio;
    }

    Connections {
        id: coldDown;
        property string pendingMd5;
        target: null;
        onStatusChanged: {
            if (audio.status != Audio.Loading){
                coldDown.target = null;
                playAudio(coldDown.pendingMd5);
            }
        }
    }
}
