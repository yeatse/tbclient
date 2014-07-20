import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
import com.yeatse.tbclient 1.0
import "Component"
import "../js/main.js" as Script

PageStackWindow {
    id: app;

    showStatusBar: inPortrait;

    initialPage: MainPage { id: mainPage; }

    platformStyle: PageStackWindowStyle {
        background: tbsettings.bgImageUrl == ""
                    ? "image://theme/meegotouch-applicationpage-background"+__invertedString
                    : "image://bgProvider/"+tbsettings.bgImageUrl+__invertedString;
        backgroundFillMode: Image.PreserveAspectCrop;
    }

    TBSettings { id: tbsettings; }

    Constant { id: constant; }

    SignalCenter { id: signalCenter; }

    InfoCenter { id: infoCenter; }

    AudioWrapper { id: audioWrapper; }

    WorkerScript {
        id: worker;
        property bool running: false;
        source: "../js/WorkerScript.js";
        onMessage: running = messageObject.running;
    }

    ImageUploader {
        id: imageUploader;
        property variant caller: null;
        function signForm(params){
            return Script.BaiduRequest.generateSignature(params);
        }
        function jsonParse(data){
            return JSON.parse(data);
        }
        uploader: HttpUploader{}
        onUploadFinished: signalCenter.imageUploadFinished(caller, result);
    }

    HttpUploader {
        id: uploader;
        property variant caller: null;
        onUploadStateChanged: Script.uploadStateChanged();
    }

    AudioRecorder {
        id: recorder;
        outputLocation: utility.tempPath+"/audio.amr";
    }

    InfoBanner { id: infoBanner; topMargin: app.showStatusBar?36:0; }

    Binding {
        target: theme;
        property: "inverted";
        value: !tbsettings.whiteTheme;
    }

    Component.onCompleted: Script.initialize(signalCenter, tbsettings, utility, worker, uploader, imageUploader);
    Component.onDestruction: utility.clearNotifications();
}
