import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import com.yeatse.tbclient 1.0
import HttpUp 1.0
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

    WorkerScript { id: worker; source: "../js/WorkerScript.js"; }

    StatusPaneText { id: statusPaneText; }

    InfoCenter { id: infoCenter; }

    AudioWrapper { id: audioWrapper; }

    HttpUploader { id: uploader; }

    AudioRecorder { id: recorder; outputLocation: utility.tempPath+"/audio.amr"; }

    ToolTip {
        id: toolTip;
        platformInverted: tbsettings.whiteTheme;
        visible: false;
    }

    InfoBanner {
        id: infoBanner;
        iconSource: "../gfx/error.svg";
        platformInverted: tbsettings.whiteTheme;
    }

    Keys.onVolumeUpPressed: audioWrapper.volumeUp();
    Keys.onVolumeDownPressed: audioWrapper.volumeDown();

    Component.onCompleted: Script.initialize(signalCenter, tbsettings, utility, worker);
}
