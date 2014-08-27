import QtQuick 1.0
import com.nokia.symbian 1.0
import "Component"
import "Profile"
import "../js/main.js" as Script

MyPage {
    id: page;

    property string uid;
    onUidChanged: getProfile();

    property variant userData: null;
    property bool isMe: getUid() === tbsettings.currentUid;
    property bool isLike: userData ? userData.has_concerned === "1" : false;

    function getUid(){
        return userData ? userData.id : uid;
    }

    function getProfile(){
        var prop = { uid: getUid() };
        loading = true;
        var s = function(obj){ loading = false; userData = obj; }
        var f = function(err){ loading = false; signalCenter.showMessage(err); }
        Script.getUserProfile(prop, s, f);
    }

    function follow(){
        var prop = { portrait: userData.portrait, isFollow: !isLike };
        var s = function(){ loading = false; isLike = prop.isFollow;
            signalCenter.showMessage(qsTr("Success")); }
        var f = function(err){ loading = false; signalCenter.showMessage(err); }
        loading = true;
        Script.followUser(prop, s, f);
    }

    title: qsTr("Profile");

    tools: ToolBarLayout {
        BackButton {}
        ToolButtonWithTip {
            toolTipText: qsTr("Refresh");
            iconSource: "toolbar-refresh";
            onClicked: getProfile();
        }
        ToolButtonWithTip {
            toolTipText: qsTr("Chat");
            iconSource: "gfx/instant_messenger_chat.svg";
            enabled: !isMe && userData != null;
            onClicked: {
                var prop = { chatName: userData.name_show, chatId: getUid() };
                pageStack.push(Qt.resolvedUrl("Message/ChatPage.qml"), prop);
            }
        }
    }

    Connections {
        target: signalCenter;
        onProfileChanged: {
            userData = null;
            getProfile();
        }
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
    }

    Image {
        id: imageBg;
        anchors { left: parent.left; right: parent.right; top: viewHeader.bottom; }
        height: constant.graphicSizeLarge*2.7 - view.contentY;
        clip: true;
        source: "gfx/profile_bg.jpg"
        fillMode: Image.PreserveAspectCrop;
    }

    Flickable {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        contentWidth: parent.width;
        contentHeight: contentCol.height;
        Column {
            id: contentCol;
            width: parent.width;
            Item { width: 1; height: constant.thumbnailSize; }
            Item {
                width: parent.width;
                height: constant.graphicSizeLarge*2;

                BorderImage {
                    id: bottomBanner;
                    anchors { fill: parent; topMargin: parent.height*3/5; }
                    source: privateStyle.imagePath("qtg_fr_list_heading_normal");
                    border { left: 28; top: 5; right: 28; bottom: 0 }
                }

                Image {
                    id: avatar;
                    anchors {
                        left: parent.left; leftMargin: constant.paddingMedium;
                        verticalCenter: parent.verticalCenter;
                    }
                    width: 100; height: 100;
                    source: "gfx/person_photo_bg.png"
                    Image {
                        anchors { fill: parent; margins: constant.paddingMedium; }
                        source: userData ? "http://himg.baidu.com/sys/portraith/item/"+userData.portraith
                                         : "gfx/photo.png";
                    }
                }

                Column {
                    anchors {
                        left: avatar.right; leftMargin: constant.paddingMedium;
                        right: parent.right; rightMargin: constant.paddingMedium;
                        bottom: bottomBanner.top;
                    }
                    Row {
                        spacing: constant.paddingSmall;
                        Text {
                            anchors.verticalCenter: parent.verticalCenter;
                            font: constant.titleFont;
                            color: constant.colorLight;
                            text: userData ? userData.name_show : "";
                        }
                        Image {
                            source: {
                                if (userData){
                                    if (userData.sex === "1"){
                                        return "gfx/icon_man.png";
                                    } else {
                                        return "gfx/icon_woman.png";
                                    }
                                } else {
                                    return "";
                                }
                            }
                        }
                    }
                    Text {
                        width: parent.width;
                        elide: Text.ElideRight;
                        textFormat: Text.PlainText;
                        font: constant.labelFont;
                        color: constant.colorLight;
                        text: userData ? userData.intro : "";
                    }
                }

                Loader {
                    anchors {
                        left: avatar.right; leftMargin: constant.paddingMedium;
                        verticalCenter: bottomBanner.verticalCenter;
                    }
                    sourceComponent: isMe ? editBtnComp : followBtnComp;
                    Component {
                        id: editBtnComp;
                        MouseArea {
                            property string pressString: pressed ? "s" : "n";
                            width: editRow.width + 20;
                            height: constant.graphicSizeMedium;
                            onClicked: pageStack.push(Qt.resolvedUrl("Profile/ProfileEditPage.qml"),
                                                      {userData: userData});
                            BorderImage {
                                anchors.fill: parent;
                                border { left: 25; right: 25; top: 0; bottom: 0; }
                                source: "gfx/btn_bg_"+parent.pressString+".png";
                                smooth: true;
                            }
                            Row {
                                id: editRow;
                                anchors.centerIn: parent;
                                spacing: constant.paddingSmall;
                                Image {
                                    anchors.verticalCenter: parent.verticalCenter;
                                    source: "gfx/btn_icon_edit.png";
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter;
                                    font: constant.subTitleFont;
                                    color: constant.colorLight;
                                    text: qsTr("Edit profile");
                                }
                            }
                        }
                    }
                    Component {
                        id: followBtnComp;
                        MouseArea {
                            property string pressString: pressed ? "s" : "n";
                            property string name: isLike ? "bg" : "like";
                            width: 114;
                            height: 46;
                            enabled: userData != null && !loading;
                            onClicked: follow();
                            BorderImage {
                                id: icon;
                                anchors.fill: parent;
                                border { left: 25; right: 25; top: 0; bottom: 0; }
                                source: "gfx/btn_%1_%2%3.png".arg(parent.name).arg(parent.pressString).arg("");
                            }
                            Text {
                                visible: isLike;
                                anchors.centerIn: parent;
                                font: constant.subTitleFont;
                                color: constant.colorLight;
                                text: qsTr("Unfollow");
                            }
                        }
                    }
                }
            }
            Grid {
                id: grid;
                width: parent.width;
                columns: 3;
                ProfileCell {
                    visible: isMe;
                    iconName: "sc";
                    title: qsTr("Collections");
                    markVisible: getUid() === tbsettings.currentUid && infoCenter.bookmark > 0;
                    onClicked: {
                        var prop = { title: title }
                        pageStack.push(Qt.resolvedUrl("Profile/BookmarkPage.qml"), prop);
                    }
                }
                ProfileCell {
                    iconName: "myba";
                    title: qsTr("Tieba");
                    subTitle: userData ? userData.my_like_num : "";
                    onClicked: {
                        var prop = { title: title, uid: getUid() }
                        pageStack.push(Qt.resolvedUrl("Profile/ProfileForumList.qml"), prop);
                    }
                }
                ProfileCell {
                    iconName: "gz";
                    title: qsTr("Concerns");
                    subTitle: userData ? userData.concern_num : "";
                    onClicked: {
                        var prop = { title: title, type: "follow", uid: getUid() }
                        pageStack.push(Qt.resolvedUrl("Profile/FriendsPage.qml"), prop);
                    }
                }
                ProfileCell {
                    iconName: "fs";
                    title: qsTr("Fans")
                    subTitle: userData ? userData.fans_num : "";
                    onClicked: {
                        if (getUid() === tbsettings.currentUid){
                            infoCenter.clear("fans");
                        }
                        var prop = { title: title, type: "fans", uid: getUid() }
                        pageStack.push(Qt.resolvedUrl("Profile/FriendsPage.qml"), prop);
                    }
                    markVisible: getUid() === tbsettings.currentUid && infoCenter.fans > 0;
                }
                ProfileCell {
                    iconName: "tiezi";
                    title: qsTr("Posts");
                    subTitle: userData ? userData.post_num : "";
                    onClicked: {
                        var prop = { title: title, uid: getUid() };
                        pageStack.push(Qt.resolvedUrl("Profile/ProfilePost.qml"), prop);
                    }
                }
            }
        }
    }

    // For keypad
    onStatusChanged: {
        if (status === PageStatus.Active){
            view.forceActiveFocus();
        }
    }
}
