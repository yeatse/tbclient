import QtQuick 1.0
import QtMultimediaKit 1.1
import QtMobility.systeminfo 1.1
import com.yeatse.tbclient 1.0
import "../../js/Utils.js" as Utils

Item {
    id: root;

    // public api:
    property string currentMd5;
    property real volume: tbsettings.volumeLevel / 10;
    property int position: audio.position;
    property bool playing: audio.playing;
    property bool loading: downloader.state == 2;

    // private:
    property string __currentFile;

    function changeFile(filename){
        audio.stop();
        if (audio.status != Audio.Loading){
            audio.source = filename;
            audio.play();
        } else {
            __currentFile = filename;
            coldDown.target = audio;
        }
    }

    function playAudio(md5){
        var filename = audioFileName(md5);
        var url = Utils.getAudioUrl(md5);
        if (currentMd5 === md5){
            if (utility.existsFile(filename)){
                if (audio.playing && !audio.paused){
                    audio.pause();
                } else {
                    audio.play();
                }
            }
        } else {
            currentMd5 = md5;
            audio.stop();
            if (utility.existsFile(filename)){
                changeFile("file:///"+filename);
            } else {
                downloader.abortDownload(true);
                downloader.appendDownload(url, filename);
            }
        }
    }

    function audioFileName(md5){
        return utility.cachePath + "/audio/" + md5 + ".mp3";
    }

    function volumeUp() {
        var maxVol = 1.0;
        var volThreshold = 0.1;
        if (root.volume < maxVol - volThreshold) {
            root.volume += volThreshold;
        } else {
            root.volume = maxVol;
        }
    }

    function volumeDown() {
        var minVol = 0.0;
        var volThreshold = 0.1;
        if (root.volume > minVol + volThreshold) {
            root.volume -= volThreshold;
        } else {
            root.volume = minVol;
        }
    }

    function stop(){
        audio.stop();
    }

    visible: false;

    Audio {
        id: audio;
        volume: root.volume;
    }

    Downloader {
        id: downloader;
        onStateChanged: {
            if (state == 3 && error == 0){
                if (currentRequest === Utils.getAudioUrl(currentMd5)){
                    changeFile("file:///"+currentFile);
                }
            }
        }
    }

    DeviceInfo {
        id: devInfo;
        /*monitorCurrentProfileChanges: true;
        onCurrentProfileChanged: {
            root.volume = devInfo.voiceRingtoneVolume / 100;
        }*/
    }

    Connections {
        id: coldDown;
        target: null;
        onStatusChanged: {
            if (audio.status != Audio.Loading){
                coldDown.target = null;
                audio.source = "file:///"+__currentFile;
                audio.play();
            }
        }
    }
}
