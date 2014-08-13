import QtQuick 1.0
import com.nokia.symbian 1.0
import com.yeatse.tbclient 1.0
import "../Component"
import "../../js/main.js" as Script
import "../../js/Utils.js" as Utils
import "PostPage.js" as Post

MyPage {
    id: page;

    property variant caller;
    property bool isReply: false;

    title: isReply ? qsTr("Send reply") : qsTr("Create a new thread");

    tools: ToolBarLayout {
        BackButton {
            onClicked: {
                tbsettings.draftBox = contentArea.text;
                Post.uploadCanceled = true;
                if (uploader.uploadState == HttpUploader.Loading){
                    uploader.abort();
                }
                imageUploader.abortUpload();
            }
        }
    }

    Connections {
        target: signalCenter;
        onUploadFailed: if (caller === page) Post.uploadFailed();
        onUploadFinished: if (caller === page) Post.uploadFinished(response);
        onImageUploadFinished: if (caller === page) Post.imageUploadFinished(result);
        onVcodeSent: if (caller === page) Post.post(vcode, vcodeMd5);
        onFriendSelected: {
            if (caller === page){
                var c = contentArea.cursorPosition;
                contentArea.text = contentArea.text.substring(0, c)+"@"+name+" "+contentArea.text.substring(c);
                contentArea.cursorPosition = c + name.length + 2;
            }
        }
        onEmoticonSelected: {
            if (caller === page){
                var c = contentArea.cursorPosition;
                contentArea.text = contentArea.text.substring(0, c)+name+contentArea.text.substring(c);
                contentArea.cursorPosition = c + name.length;
            }
        }
    }

    Timer {
        id: postTimer;
        interval: 100;
        onTriggered: Post.post();
    }

    ViewHeader {
        id: viewHeader;
        visible: app.inPortrait;
        title: page.title;
    }

    TextField {
        id: titlefield;
        property bool acceptableInput: Utils.TextSlicer.textLength(text) <= 60;
        visible: !isReply;
        height: visible ? implicitHeight : 0;
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.top: viewHeader.bottom;
        anchors.margins: constant.paddingMedium;
        //platformInverted: tbsettings.whiteTheme;
        KeyNavigation.down: contentArea;
        Keys.onPressed: {
            if (event.key == Qt.Key_Select
                    ||event.key == Qt.Key_Enter
                    ||event.key == Qt.Key_Return){
                contentArea.forceActiveFocus();
                contentArea.openSoftwareInputPanel();
                event.accepted = true;
            }
        }
    }

    TextArea {
        id: contentArea;
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.top: isReply ? viewHeader.bottom : titlefield.bottom;
        anchors.bottom: undefined;
        anchors.margins: constant.paddingMedium;
        height: screen.height
                - privateStyle.statusBarHeight
                - viewHeader.height
                - titlefield.height
                - toolsBanner.height
                - attachedArea.height
                - constant.paddingMedium*4;
        //platformInverted: tbsettings.whiteTheme;
        text: tbsettings.draftBox;
    }

    Item {
        id: toolsBanner;
        anchors {
            left: parent.left; right: parent.right;
            top: contentArea.bottom; margins: constant.paddingMedium;
        }
        height: childrenRect.height;
        Row {
            id: toolsRow;
            spacing: constant.paddingSmall;
            ToolButton {
                //platformInverted: tbsettings.whiteTheme;
                iconSource: "../gfx/btn_insert_face.png"
                onClicked: signalCenter.createEmoticonDialog(page);
            }
            ToolButton {
                //platformInverted: tbsettings.whiteTheme;
                iconSource: "../gfx/btn_insert_at.png";
                onClicked: {
                    var prop = { type: "at", caller: page }
                    pageStack.push(Qt.resolvedUrl("../Profile/SelectFriendPage.qml"), prop);
                }
            }
            ToolButton {
                id: picBtn;
                checkable: true;
                //platformInverted: tbsettings.whiteTheme;
                iconSource: "../gfx/btn_insert_pics.png";
                onClicked: attachedArea.state = attachedArea.state == "Image" ? "" : "Image";
                Image {
                    anchors { top: parent.top; right: parent.right; }
                    source: "../gfx/ico_mbar_news_point.png";
                    visible: attachedArea.imageList.length > 0;
                }
            }
            ToolButton {
                id: voiBtn;
                checkable: true;
                //platformInverted: tbsettings.whiteTheme;
                iconSource: "../gfx/btn_insert_voice.png";
                onClicked: attachedArea.state = attachedArea.state == "Voice" ? "" : "Voice";
                Image {
                    anchors { top: parent.top; right: parent.right; }
                    source: "../gfx/ico_mbar_news_point.png";
                    visible: attachedArea.audioFile.length > 0;
                }
            }
        }
        ToolButton {
            anchors.top: app.inPortrait ? toolsRow.bottom : parent.top;
            anchors.right: parent.right;
            //platformInverted: tbsettings.whiteTheme;
            enabled: !loading && attachedArea.enabled;
            text: qsTr("Post");
            onClicked: postTimer.start();
        }
    }

    AttachedArea {
        id: attachedArea;
        enabled: (uploader.uploadState != HttpUploader.Loading||uploader.caller != page)
                 &&(!imageUploader.isRunning||imageUploader.caller != page);
        onStateChanged: {
            picBtn.checked = state === "Image";
            voiBtn.checked = state === "Voice";
        }
        BusyIndicator {
            anchors.centerIn: parent;
            running: true;
            width: constant.graphicSizeLarge;
            height: constant.graphicSizeLarge;
            //platformInverted: tbsettings.whiteTheme;
            visible: !(attachedArea.enabled||attachedArea.state=="");
        }
        ProgressBar {
            anchors.bottom: parent.bottom;
            width: parent.width;
            value: imageUploader.isRunning ? imageUploader.progress : uploader.progress;
            //platformInverted: tbsettings.whiteTheme;
            visible: !(attachedArea.enabled||attachedArea.state=="");
        }
    }

    states: [
        State {
            name: "VKBOpened";
            PropertyChanges { target: viewHeader; visible: false; }
            PropertyChanges { target: contentArea; height: undefined; }
            AnchorChanges { target: contentArea; anchors.bottom: page.bottom; }
            PropertyChanges { target: toolsBanner; visible: false; }
            PropertyChanges { target: attachedArea; visible: false; }
            when: app.platformSoftwareInputPanelEnabled && inputContext.visible;
        }
    ]

    // for keypad
    Connections {
        target: platformPopupManager;
        onPopupStackDepthChanged: {
            if (platformPopupManager.popupStackDepth === 0
                    && page.status === PageStatus.Active){
                contentArea.forceActiveFocus();
            }
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active){
            if (titlefield.visible && contentArea.text.length == 0){
                titlefield.forceActiveFocus();
            } else {
                contentArea.forceActiveFocus();
            }
        } else if (status === PageStatus.Deactivating){
            attachedArea.state = "";
        }
    }
}
