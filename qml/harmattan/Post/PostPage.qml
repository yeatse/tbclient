import QtQuick 1.1
import com.nokia.meego 1.1
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
        Button {
            anchors {
                right: parent.right;
                rightMargin: constant.paddingXLarge;
                verticalCenter: parent.verticalCenter;
            }
            platformStyle: ButtonStyle {
                buttonWidth: 150; buttonHeight: 42;
            }
            text: "返回";
            onClicked: {
                tbsettings.draftBox = contentArea.text;
                Post.uploadCanceled = true;
                if (uploader.uploadState == HttpUploader.Loading){
                    uploader.abort();
                }
                imageUploader.abortUpload();
                pageStack.pop();
            }
        }
    }

    Flickable {
        id: view;
        anchors {
            left: parent.left; right: parent.right;
            top: viewHeader.bottom; bottom: toolsBanner.top;
        }
        clip: true;
        boundsBehavior: Flickable.StopAtBounds;
        contentWidth: parent.width;
        contentHeight: contentCol.height+constant.paddingLarge*2;

        Column {
            id: contentCol;
            anchors {
                left: parent.left; right: parent.right;
                top: parent.top; margins: constant.paddingLarge;
            }
            width: parent.width;
            spacing: constant.paddingLarge;

            TextField {
                id: titlefield;
                property bool acceptableInput: Utils.TextSlicer.textLength(text) <= 60;
                width: parent.width;
                height: visible ? implicitHeight : 0;
                visible: !isReply;
            }

            TextArea {
                id: contentArea;
                property int minHeight: view.height - titlefield.height - constant.paddingLarge*3;
                width: parent.width;
                textFormat: TextEdit.PlainText;
                text: tbsettings.draftBox;
                function setHeight(){ contentArea.height = Math.max(implicitHeight, minHeight); }
                onMinHeightChanged: setHeight();
                onImplicitHeightChanged: setHeight();
            }
        }
    }

    Item {
        id: toolsBanner;
        anchors {
            left: parent.left; right: parent.right;
            bottom: parent.bottom; margins: constant.paddingLarge;
        }
        height: toolsRow.height+attachedArea.height;
        ButtonStyle { id: toolBtnStyle; buttonWidth: buttonHeight; }
        Row {
            id: toolsRow;
            spacing: constant.paddingSmall;
            Button {
                platformStyle: toolBtnStyle;
                iconSource: "../gfx/btn_insert_face"+constant.invertedString;
                onClicked: signalCenter.createEmoticonDialog(page);
            }
            Button {
                platformStyle: toolBtnStyle;
                iconSource: "../gfx/btn_insert_at"+constant.invertedString;
                onClicked: {
                    var prop = { type: "at", caller: page }
                    pageStack.push(Qt.resolvedUrl("../Profile/SelectFriendPage.qml"), prop);
                }
            }
            Button {
                id: picBtn;
                platformStyle: toolBtnStyle;
                checkable: true;
                iconSource: "../gfx/btn_insert_pics"+constant.invertedString;
                onClicked: attachedArea.state = attachedArea.state == "Image" ? "" : "Image";
                Image {
                    anchors { top: parent.top; right: parent.right; }
                    source: "../gfx/ico_mbar_news_point.png";
                    visible: attachedArea.imageList.length > 0;
                }
            }
            Button {
                id: voiBtn;
                platformStyle: toolBtnStyle;
                checkable: true;
                iconSource: "../gfx/btn_insert_voice"+constant.invertedString;
                onClicked: attachedArea.state = attachedArea.state == "Voice" ? "" : "Voice";
                Image {
                    anchors { top: parent.top; right: parent.right; }
                    source: "../gfx/ico_mbar_news_point.png";
                    visible: attachedArea.audioFile.length > 0;
                }
            }
        }
        Button {
            anchors.right: parent.right;
            platformStyle: ButtonStyle {
                buttonWidth: buttonHeight*2;
                inverted: !theme.inverted;
            }
            enabled: !loading && attachedArea.enabled;
            text: qsTr("Post");
            onClicked: postTimer.start();
        }
        AttachedArea {
            id: attachedArea;
            anchors.top: toolsRow.bottom;
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
                visible: !(attachedArea.enabled||attachedArea.state=="");
            }
            ProgressBar {
                anchors.bottom: parent.bottom;
                width: parent.width;
                value: imageUploader.isRunning ? imageUploader.progress : uploader.progress;
                visible: !(attachedArea.enabled||attachedArea.state=="");
            }
        }
    }

    Rectangle {
        id: bgRect;
        z: 100;
        anchors { fill: parent; topMargin: viewHeader.height; }
        color: "#A0000000";
        visible: page.loading;
        BusyIndicator {
            anchors.centerIn: parent;
            platformStyle: BusyIndicatorStyle {
                size: "large";
                inverted: true;
            }
            running: true;
        }
        MouseArea {
            anchors.fill: parent;
        }
    }

    Connections {
        target: inputContext;
        onSoftwareInputPanelVisibleChanged: {
            if (inputContext.softwareInputPanelVisible){
                attachedArea.state = "";
            }
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active){
            if (titlefield.visible && contentArea.text.length == 0){
                titlefield.forceActiveFocus();
                titlefield.platformOpenSoftwareInputPanel();
            } else {
                contentArea.forceActiveFocus();
                contentArea.platformOpenSoftwareInputPanel();
            }
        } else if (status === PageStatus.Deactivating){
            attachedArea.state = "";
        }
    }
}
