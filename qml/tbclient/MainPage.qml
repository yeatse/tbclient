import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "Silica"
import "../js/main.js" as Script
import QtWebKit 1.0

MyPage {
    id: page;

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
        }
        ToolButtonWithTip {
            toolTipText: qsTr("Messages");
            iconSource: "../gfx/messaging"+constant.invertedString+".svg"
            onClicked: pageStack.push(Qt.resolvedUrl("Message/MessagePage.qml"))
        }
        ToolButtonWithTip {
            toolTipText: qsTr("User center");
            iconSource: "../gfx/contacts"+constant.invertedString+".svg"
        }
        ToolButtonWithTip {
            toolTipText: qsTr("More");
            iconSource: "../gfx/toolbar_extension"+constant.invertedString+".svg"
            onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"));
        }
    }

    Connections {
        target: signalCenter;
        onUserChanged: {
            internal.initialize();
        }
    }

    QtObject {
        id: internal;

        function initialize(){
            if (!Script.loadLikeForum(view.model)){
                getLikedForum();
            }
        }

        function getLikedForum(){
            loading = true;
            var opt = { model: view.model };
            function s(){
                loading = false;
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
            } else {
                color = "red";
            }
            return "../gfx/icon_grade_"+color + constant.invertedString+".png";
        }
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
        onClicked: view.scrollToTop();
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
                        anchors.verticalCenter: parent.verticalCenter;
                        width: signText.width + 16;
                        source: "../gfx/ico_sign"+constant.invertedString+".png"
                        visible: is_sign;
                        Text {
                            id: signText;
                            anchors.centerIn: parent;
                            font.pixelSize: constant.fontXSmall;
                            color: "darkred";
                            text: is_sign ? qsTr("signed") : "";
                        }
                    }
                    Image {
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
        platformInverted: tbsettings.whiteTheme;
    }

    // For keypad
    onStatusChanged: {
        if (status === PageStatus.Active){
            view.forceActiveFocus();
        }
    }
    Keys.onPressed: {
        if (event.key === Qt.Key_Backspace){
            quitButton.clicked();
            event.accepted = true;
        }
    }
}
