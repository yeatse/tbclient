import QtQuick 1.1
import com.nokia.symbian 1.1
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

    tools: ToolBarLayout {
        BackButton {}
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
        source: "../gfx/profile_bg.jpg"
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
                    source: privateStyle.imagePath("qtg_fr_list_heading_normal", tbsettings.whiteTheme);
                    border { left: 28; top: 5; right: 28; bottom: 0 }
                }

                Image {
                    id: avatar;
                    anchors {
                        left: parent.left; leftMargin: constant.paddingMedium;
                        verticalCenter: parent.verticalCenter;
                    }
                    width: 100; height: 100;
                    source: "../gfx/person_photo_bg.png"
                    Image {
                        anchors { fill: parent; margins: constant.paddingMedium; }
                        source: userData ? "http://tb.himg.baidu.com/sys/portraith/item/"+userData.portraith
                                         : "../gfx/photo.png";
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
                                        return "../gfx/icon_man"+constant.invertedString+".png";
                                    } else {
                                        return "../gfx/icon_woman"+constant.invertedString+".png";
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
                        wrapMode: Text.Wrap;
                        maximumLineCount: 1;
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
                            BorderImage {
                                anchors.fill: parent;
                                border { left: 25; right: 25; top: 0; bottom: 0; }
                                source: "../gfx/btn_bg_"+parent.pressString+constant.invertedString+".png";
                                smooth: true;
                            }
                            Row {
                                id: editRow;
                                anchors.centerIn: parent;
                                spacing: constant.paddingSmall;
                                Image {
                                    anchors.verticalCenter: parent.verticalCenter;
                                    source: "../gfx/btn_icon_edit"+constant.invertedString+".png";
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
                            Image {
                                id: icon;
                                source: "../gfx/btn_%1_%2%3.png".arg(parent.name).arg(parent.pressString).arg(constant.invertedString);
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
                }
                ProfileCell {
                    iconName: "myba";
                    title: qsTr("Tieba");
                    subTitle: userData ? userData.like_forum_num : "";
                    onClicked: {
                        var prop = { title: title, uid: getUid() }
                        pageStack.push(Qt.resolvedUrl("Profile/ProfileForumList.qml"), prop);
                    }
                }
                ProfileCell {
                    iconName: "gz";
                    title: qsTr("Concerns");
                    subTitle: userData ? userData.concern_num : "";
                }
                ProfileCell {
                    iconName: "fs";
                    title: qsTr("Fans")
                    subTitle: userData ? userData.fans_num : "";
                }
                ProfileCell {
                    iconName: "tiezi";
                    title: qsTr("Posts");
                    subTitle: userData ? userData.post_num : "";
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
