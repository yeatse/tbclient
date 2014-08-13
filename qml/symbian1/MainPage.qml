import QtQuick 1.0
import com.nokia.symbian 1.0
import "Component"
import "Silica"
import "../js/main.js" as Script

MyPage {
    id: page;

    property bool forceRefresh: false;

    loadingVisible: loading && view.count === 0;

    title: qsTr("My tieba");

    tools: ToolBarLayout {
        ToolButtonWithTip {
            id: quitButton;
            toolTipText: qsTr("Quit");
            iconSource: "toolbar-back";
            onClicked: {
                if (quitTimer.running){
                    Qt.quit();
                } else {
                    quitTimer.start();
                    signalCenter.showMessage(qsTr("Press again to quit"));
                }
            }
            Timer {
                id: quitTimer;
                interval: infoBanner.timeout;
            }
        }
        ToolButtonWithTip {
            toolTipText: qsTr("Home page");
            iconSource: "toolbar-home";
            onClicked: pageStack.push(Qt.resolvedUrl("Explore/FeedPage.qml"));
        }
        ToolButtonWithTip {
            toolTipText: qsTr("Messages");
            iconSource: "gfx/messaging.svg"
            onClicked: pageStack.push(Qt.resolvedUrl("Message/MessagePage.qml"))
            Bubble {
                anchors.verticalCenter: parent.top;
                anchors.horizontalCenter: parent.horizontalCenter;
                text: {
                    var n = 0;
                    if (tbsettings.remindAtme) n += infoCenter.atme;
                    if (tbsettings.remindPletter) n += infoCenter.pletter;
                    if (tbsettings.remindReplyme) n += infoCenter.replyme;
                    return n>0 ? n : "";
                }
                visible: text != "";
            }
        }
        ToolButtonWithTip {
            toolTipText: qsTr("User center");
            iconSource: "gfx/contacts.svg"
            onClicked: pageStack.push(Qt.resolvedUrl("ProfilePage.qml"), { uid: tbsettings.currentUid })
            Bubble {
                anchors.verticalCenter: parent.top;
                anchors.horizontalCenter: parent.horizontalCenter;
                text: {
                    var n = 0;
                    if (tbsettings.remindBookmark) n += infoCenter.bookmark;
                    if (tbsettings.remindFans) n += infoCenter.fans;
                    return n>0 ? n : "";
                }
                visible: text != "";
            }
        }
        ToolButtonWithTip {
            toolTipText: qsTr("More");
            iconSource: "gfx/toolbar_extension.svg"
            onClicked: pageStack.push(Qt.resolvedUrl("MorePage.qml"));
        }
    }

    Connections {
        target: signalCenter;
        onUserChanged: {
            Script.register();
            internal.initialize();
        }
        onForumSigned: {
            if (internal.fromNetwork){
                for (var i=0; i<view.model.count; i++){
                    if (fid === view.model.get(i).forum_id){
                        view.model.setProperty(i, "is_sign", true);
                        break;
                    }
                }
            } else {
                page.forceRefresh = true;
            }
        }
    }

    QtObject {
        id: internal;

        property bool fromNetwork: false;

        function initialize(){
            if (!Script.DBHelper.loadLikeForum(view.model)){
                getLikedForum();
            }
        }

        function getLikedForum(){
            loading = true;
            var opt = { model: view.model };
            function s(){
                loading = false;
                fromNetwork = true;
            }
            function f(err){
                loading = false;
                signalCenter.showMessage(err);
            }
            Script.getRecommentForum(opt, s, f);
        }

        function getGradeIcon(lv){
            var color = "";
            if (lv <= 3){
                color = "green";
            } else if (lv <= 10){
                color = "blue";
            } else if (lv <= 15) {
                color = "red";
            } else {
                color = "yellow";
            }
            return "gfx/icon_grade_"+color+".png";
        }
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
        onClicked: view.scrollToTop();
        ToolButton {
            anchors {
                right: parent.right; rightMargin: constant.paddingMedium;
                verticalCenter: parent.verticalCenter;
            }
            iconSource: "gfx/calendar_week.svg";
            onClicked: pageStack.push(Qt.resolvedUrl("BatchSignPage.qml"));
        }
    }

    SilicaListView {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        model: ListModel {}
        header: headerComp;
        delegate: forumDelegate;
        Component {
            id: headerComp;
            Item {
                id: root;
                width: screen.width;
                height: constant.graphicSizeLarge;
                PullToActivate {
                    myView: view;
                    onRefresh: internal.getLikedForum();
                }
                SearchInput {
                    anchors {
                        left: parent.left; leftMargin: constant.paddingLarge;
                        right: searchBtn.left; rightMargin: constant.paddingMedium;
                        verticalCenter: parent.verticalCenter;
                    }
                    placeholderText: qsTr("Tap to search");
                }
                Rectangle {
                    anchors.bottom: parent.bottom;
                    width: parent.width;
                    height: 1;
                    color: constant.colorMarginLine;
                }
                MouseArea {
                    anchors.fill: parent;
                    onClicked: searchBtn.clicked();
                }
                Button {
                    id: searchBtn;
                    anchors {
                        right: parent.right; rightMargin: constant.paddingLarge;
                        verticalCenter: parent.verticalCenter;
                    }
                    width: height;
                    iconSource: privateStyle.toolBarIconPath("toolbar-mediacontrol-play");
                    onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml"),
                                              undefined, true);
                }
            }
        }
        Component {
            id: forumDelegate;
            AbstractItem {
                id: root;
                onClicked: signalCenter.enterForum(forum_name);
                Text {
                    anchors {
                        left: root.paddingItem.left;
                        verticalCenter: parent.verticalCenter;
                    }
                    text: forum_name;
                    font: constant.titleFont;
                    color: constant.colorLight;
                }
                Row {
                    id: infoIcon;
                    anchors { right: root.paddingItem.right; verticalCenter: parent.verticalCenter; }
                    spacing: constant.paddingMedium;
                    Image {
                        asynchronous: true;
                        anchors.verticalCenter: parent.verticalCenter;
                        width: signText.width + 20;
                        height: Math.floor(width/111*46);
                        //source: "gfx/ico_sign.png"
                        source: "gfx/ico_sign.png"
                        visible: is_sign;
                        Text {
                            id: signText;
                            anchors.centerIn: parent;
                            font: constant.subTitleFont;
                            color: "darkred";
                            text: is_sign ? qsTr("signed") : "";
                        }
                    }
                    Image {
                        asynchronous: true;
                        anchors.verticalCenter: parent.verticalCenter;
                        source: internal.getGradeIcon(level_id);
                        Text {
                            anchors.centerIn: parent;
                            font.pixelSize: constant.fontXSmall;
                            color: "white";
                            text: level_id;
                        }
                    }
                }
            }
        }
    }

    ScrollBar {
        anchors { right: view.right; top: view.top; }
        flickableItem: view;
        //platformInverted: tbsettings.whiteTheme;
    }

    // For keypad
    onStatusChanged: {
        if (status === PageStatus.Active){
            view.forceActiveFocus();
            if (page.forceRefresh){
                page.forceRefresh = false;
                internal.getLikedForum();
            }
        }
    }
    Keys.onPressed: {
        if (event.key === Qt.Key_Backspace){
            quitButton.clicked();
            event.accepted = true;
        }
    }
}
