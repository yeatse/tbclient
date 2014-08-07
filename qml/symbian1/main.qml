import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import com.yeatse.tbclient 1.0
import "Component"
import "../js/main.js" as Script

PageStackWindow {
    id: app;

    platformInverted: tbsettings.whiteTheme;
    platformSoftwareInputPanelEnabled: utility.qtVersion > 0x040800;
    showStatusBar: inPortrait || !(platformSoftwareInputPanelEnabled && inputContext.visible);

    initialPage: MainPage { id: mainPage; }

    TBSettings { id: tbsettings; }

    Constant { id: constant; }

    SignalCenter { id: signalCenter; }

    StatusPaneText { id: statusPaneText; }

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
        uploader: HttpUploader {}
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

    ToolTip {
        id: toolTip;
        platformInverted: tbsettings.whiteTheme;
        visible: false;
    }

    InfoBanner {
        id: infoBanner;
        iconSource: "gfx/error.svg";
        platformInverted: tbsettings.whiteTheme;
    }

    // Background image
    Image {
        id: background;
        z: -1;
        parent: pageStack;
        width: screen.width; height: screen.height;
        sourceSize.height: 640;
        fillMode: Image.PreserveAspectCrop;
        asynchronous: true;
        source: tbsettings.bgImageUrl;
        visible: status === Image.Ready;
        opacity: tbsettings.whiteTheme ? 0.7 : 0.5;
    }

    Keys.onVolumeUpPressed: audioWrapper.volumeUp();
    Keys.onVolumeDownPressed: audioWrapper.volumeDown();

    Component.onCompleted: Script.initialize(signalCenter, tbsettings, utility, worker, uploader, imageUploader);
}
