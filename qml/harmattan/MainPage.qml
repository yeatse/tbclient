import QtQuick 1.1
import com.nokia.meego 1.1
import "Component"
import "Silica"
import "../js/main.js" as Script

MyPage {
    id: page;

    property bool forceRefresh: false;

    loadingVisible: loading && view.count === 0;

    title: qsTr("My tieba");

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-home";
            onClicked: pageStack.push(Qt.resolvedUrl("Explore/FeedPage.qml"));
        }
        ToolIcon {
            platformIconId: "toolbar-new-message";
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
        ToolIcon {
            platformIconId: "toolbar-contact";
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
        ToolIcon {
            platformIconId: "toolbar-view-menu";
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
            return "gfx/icon_grade_".concat(color, constant.invertedString);
        }
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
        onClicked: view.scrollToTop();
        ToolIcon {
            anchors {
                right: parent.right; rightMargin: constant.paddingMedium;
                verticalCenter: parent.verticalCenter;
            }
            iconSource: "image://theme/icon-m-toolbar-clock-white";
            platformIconId: "toolbar-clock";
            onClicked: pageStack.push(Qt.resolvedUrl("BatchSignPage.qml"));
        }
    }

    SilicaGridView {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        model: ListModel {}
        pressDelay: 120;
        cacheBuffer: 2000;
        cellWidth: width / 2;
        cellHeight: constant.graphicSizeLarge;
        header: headerComp;
        delegate: forumDelegate;
        Component {
            id: headerComp;
            Item {
                id: root;
                width: view.width;
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
                    platformStyle: ButtonStyle { buttonWidth: buttonHeight; }
                    iconSource: "image://theme/icon-m-toolbar-mediacontrol-play"+(theme.inverted?"-white":"");
                    onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml"), undefined, true);
                }
            }
        }
        Component {
            id: forumDelegate;
            Item {
                id: root;
                width: view.cellWidth;
                height: view.cellHeight;
                BorderImage {
                    id: background;
                    anchors {
                        fill: parent;
                        margins: constant.paddingSmall;
                    }
                    border {
                        left: 10; top: 10;
                        right: 10; bottom: 10;
                    }
                    source: "gfx/bg_pop_choose_"+(mouseArea.pressed?"s":"n")+constant.invertedString;
                }
                Text {
                    anchors {
                        left: background.left; leftMargin: 16;
                        right: infoIcon.left;
                        verticalCenter: parent.verticalCenter;
                    }
                    text: forum_name;
                    font: constant.labelFont;
                    color: constant.colorLight;
                    wrapMode: Text.Wrap;
                    elide: Text.ElideRight;
                    maximumLineCount: 2;
                }
                Row {
                    id: infoIcon;
                    anchors {
                        right: background.right;
                        rightMargin: 10;
                        verticalCenter: parent.verticalCenter;
                    }
                    Image {
                        anchors.verticalCenter: parent.verticalCenter;
                        source: "gfx/icon_jinba_sign"+constant.invertedString;
                        visible: is_sign;
                        Text {
                            id: signText;
                            anchors.fill: parent;
                            verticalAlignment: Text.AlignVCenter;
                            horizontalAlignment: Text.AlignHCenter;
                            elide: Text.ElideRight;
                            font {
                                pixelSize: constant.fontXSmall - 2;
                                family: "Nokia Pure Text";
                                weight: Font.Light;
                            }
                            color: "red";
                            text: is_sign ? qsTr("signed") : "";
                        }
                    }
                    Image {
                        asynchronous: true;
                        anchors.verticalCenter: parent.verticalCenter;
                        source: internal.getGradeIcon(level_id);
                        Text {
                            id: levelText;
                            anchors.fill: parent;
                            verticalAlignment: Text.AlignVCenter;
                            horizontalAlignment: Text.AlignHCenter;
                            font {
                                pixelSize: constant.fontXSmall;
                                family: "Nokia Pure Text";
                                weight: Font.Light;
                            }
                            color: "white";
                            text: level_id;
                        }
                    }
                }
                MouseArea {
                    id: mouseArea;
                    anchors.fill: parent;
                    onClicked: signalCenter.enterForum(forum_name);
                }
            }
        }
    }

    ScrollDecorator {
        flickableItem: view;
    }

    onStatusChanged: {
        if (status === PageStatus.Active){
            if (page.forceRefresh){
                page.forceRefresh = false;
                internal.getLikedForum();
            }
        }
    }
}
