import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"
import "../../js/main.js" as Script

MyPage {
    id: page;

    title: qsTr("Edit profile");

    tools: ToolBarLayout {
        BackButton {}
    }

    property variant userData;
    property string avatarUrl;

    Flickable {
        id: view;
        anchors.fill: parent;
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
            ListHeading {
                platformInverted: tbsettings.whiteTheme;
                ListItemText {
                    anchors.fill: parent.paddingItem;
                    platformInverted: parent.platformInverted;
                    role: "Heading";
                    text: qsTr("Avatar");
                }
            }
            AbstractItem {
                height: 110 + constant.paddingLarge*2;
                onClicked: {
                    var url = utility.selectImage();
                    if (url !== ""){
                        var prop = { imageUrl: url, caller: page }
                        pageStack.push(Qt.resolvedUrl("AvatarEditPage.qml"), prop);
                    }
                }
                Image {
                    id: avatarImage;
                    anchors { left: parent.paddingItem.left; top: parent.paddingItem.top; }
                    width: 110; height: 110;
                    source: avatarUrl||(userData?"http://tb.himg.baidu.com/sys/portraith/item/"+userData.portraith:"");
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
            ListHeading {
                platformInverted: tbsettings.whiteTheme;
                ListItemText {
                    anchors.fill: parent.paddingItem;
                    platformInverted: parent.platformInverted;
                    role: "Heading";
                    text: qsTr("Gender");
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
                    RadioButton {
                        id: btn1;
                        platformInverted: tbsettings.whiteTheme;
                        text: qsTr("Male");
                    }
                    RadioButton {
                        id: btn2;
                        platformInverted: tbsettings.whiteTheme;
                        text: qsTr("Female");
                    }
                }
            }
            ListHeading {
                platformInverted: tbsettings.whiteTheme;
                ListItemText {
                    anchors.fill: parent.paddingItem;
                    platformInverted: parent.platformInverted;
                    role: "Heading";
                    text: qsTr("Intro");
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
                    platformMaxImplicitHeight: 150;
                    platformInverted: tbsettings.whiteTheme;
                    onActiveFocusChanged: view.positionToBottom();
                }
            }
        }
    }
}
