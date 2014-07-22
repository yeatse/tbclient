import QtQuick 1.1
import com.nokia.meego 1.1
import "../Component"
import "../../js/main.js" as Script

MyPage {
    id: page;

    title: qsTr("Edit profile");

    tools: ToolBarLayout {
        BackButton {}
        ToolIcon {
            platformIconId: "toolbar-done";
            onClicked: save();
        }
    }

    property variant userData;
    property string avatarUrl;
    property bool saving: false;

    function save(){
        var opt = {
            intro: introArea.text,
            sex: btn1.checked ? "1" : "2"
        }
        var s = function(){
            saving = false;
            if (avatarUrl !== ""){
                saving = true;
                Script.uploadAvatar(page, avatarUrl);
            } else {
                signalCenter.profileChanged();
                signalCenter.showMessage(qsTr("Success"));
                pageStack.pop();
            }
        }
        var f = function(err){
            saving = false;
            signalCenter.showMessage(err);
        }
        saving = true;
        Script.modifyProfile(opt, s, f);
    }

    Connections {
        target: signalCenter;
        onUploadFinished: {
            if (caller === page){
                saving = false;
                signalCenter.profileChanged();
                signalCenter.showMessage(qsTr("Success"));
                pageStack.pop();
            }
        }
        onUploadFailed: {
            if (caller === page){
                saving = false;
                signalCenter.showMessage(qsTr("Avatar uploading failed"));
            }
        }
        onImageSelected: {
            if (caller === page){
                var prop = { imageUrl: urls, caller: page }
                pageStack.push(Qt.resolvedUrl("AvatarEditPage.qml"), prop);
            }
        }
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
    }

    Flickable {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        contentWidth: parent.width;
        contentHeight: contentCol.height;
        boundsBehavior: Flickable.StopAtBounds;
        onHeightChanged: positionToBottom();
        onContentHeightChanged: positionToBottom();

        function positionToBottom(){
            if (introArea.activeFocus){
                view.contentY = Math.max(0, contentHeight - height);
            }
        }

        Column {
            id: contentCol;
            width: parent.width;
            Rectangle {
                width: parent.width;
                height: headingLeftLabel.height + constant.paddingMedium*2;
                color: theme.inverted ? "#2c3543" : "#e6e8ea"
                Text {
                    id: headingLeftLabel;
                    anchors {
                        left: parent.left; leftMargin: constant.paddingMedium;
                        verticalCenter: parent.verticalCenter;
                    }
                    text: qsTr("Avatar");
                    font: constant.subTitleFont;
                    color: constant.colorMid;
                }
            }
            AbstractItem {
                height: 110 + constant.paddingLarge*2;
                onClicked: {
                    signalCenter.selectImage(page);
                }
                Image {
                    id: avatarImage;
                    anchors { left: parent.paddingItem.left; top: parent.paddingItem.top; }
                    width: 110; height: 110;
                    source: avatarUrl||(userData?"http://himg.baidu.com/sys/portraith/item/"+userData.portraith+"?t="+Date.now():"");
                    asynchronous: true;
                    cache: false;
                }
                Text {
                    anchors {
                        left: avatarImage.right; right: parent.right;
                        margins: constant.paddingLarge; verticalCenter: parent.verticalCenter;
                    }
                    font: constant.labelFont;
                    color: constant.colorLight;
                    horizontalAlignment: Text.AlignHCenter;
                    text: qsTr("Edit avatar");
                }
            }
            Rectangle {
                width: parent.width;
                height: headingLeftLabel.height + constant.paddingMedium*2;
                color: theme.inverted ? "#2c3543" : "#e6e8ea"
                Text {
                    anchors {
                        left: parent.left; leftMargin: constant.paddingMedium;
                        verticalCenter: parent.verticalCenter;
                    }
                    text: qsTr("Gender");
                    font: constant.subTitleFont;
                    color: constant.colorMid;
                }
            }
            Item {
                width: parent.width; height: constant.graphicSizeLarge;
                ButtonRow {
                    id: btnRow;
                    anchors {
                        left: parent.left; right: parent.right;
                        margins: constant.paddingLarge;
                        verticalCenter: parent.verticalCenter;
                    }
                    spacing: constant.paddingLarge;
                    RadioButton {
                        id: btn1;
                        text: qsTr("Male");
                    }
                    RadioButton {
                        id: btn2;
                        text: qsTr("Female");
                    }
                }
            }
            Rectangle {
                width: parent.width;
                height: headingLeftLabel.height + constant.paddingMedium*2;
                color: theme.inverted ? "#2c3543" : "#e6e8ea"
                Text {
                    anchors {
                        left: parent.left; leftMargin: constant.paddingMedium;
                        verticalCenter: parent.verticalCenter;
                    }
                    text: qsTr("Intro");
                    font: constant.subTitleFont;
                    color: constant.colorMid;
                }
            }
            Item {
                width: parent.width;
                height: introArea.height + constant.paddingLarge*2;
                TextArea {
                    id: introArea;
                    anchors {
                        left: parent.left; right: parent.right;
                        top: parent.top; margins: constant.paddingLarge;
                    }
                    text: userData ? userData.intro : "";
                }
            }
        }
    }

    Rectangle {
        id: bgRect;
        z: 100;
        anchors.fill: parent;
        color: "#A0000000";
        visible: saving;
        Column {
            anchors.centerIn: parent;
            spacing: constant.paddingSmall;
            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter;
                running: true;
                platformStyle: BusyIndicatorStyle {
                    size: "large";
                    inverted: true;
                }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter;
                font: constant.titleFont;
                color: "white";
                text: page.loadingText;
            }
        }
        MouseArea {
            anchors.fill: parent;
        }
    }
}
