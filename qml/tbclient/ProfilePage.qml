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

    function getUid(){
        return userData ? userData.id : uid;
    }

    function getProfile(){
        var prop = { uid: uid };
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
        height: bottomBanner.mapToItem(page, 0, 0).y - viewHeader.height;
        clip: true;
        source: "../gfx/profile_bg.jpg"
        fillMode: Image.PreserveAspectCrop;
    }

    Flickable {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        contentWidth: parent.width;
        contentHeight: contentCol.height;
        onContentYChanged: imageBg.height = bottomBanner.mapToItem(page, 0, 0).y - viewHeader.height;

        Column {
            id: contentCol;
            width: parent.width;
            Item { width: 1; height: constant.thumbnailSize; }
            Item {
                width: parent.width;
                height: constant.thumbnailSize;

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
                    width: 80; height: 80;
                    source: "../gfx/person_photo_bg.png"
                    Image {
                        anchors { fill: parent; margins: constant.paddingSmall; }
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
            }
            Grid {
                id: grid;
                width: parent.width;
                columns: 3;
                ProfileCell {
                    iconName: "sc";
                    title: qsTr("Collections");
                }
                ProfileCell {
                    iconName: "myba";
                    title: qsTr("Tieba");
                    subTitle: userData ? userData.like_forum_num : "";
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
}
