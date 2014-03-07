import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"
import "../Silica"
import "../../js/main.js" as Script

MyPage {
    id: page;

    property variant squareData: null;

    function getlist(){
        var s = function(obj){ squareData = obj; loading = false; }
        var f = function(err){ signalCenter.showMessage(err); loading = false; }
        loading = true;
        Script.getForumSquare(s, f);
    }

    title: qsTr("Square");
    loadingVisible: loading && squareData == null;

    tools: ToolBarLayout {
        BackButton {}
        ToolButtonWithTip {
            toolTipText: qsTr("Refresh");
            iconSource: "toolbar-refresh";
            onClicked: getlist();
        }
        ToolButtonWithTip {
            toolTipText: qsTr("Catalogue");
            iconSource: "toolbar-list";
            onClicked: pageStack.push(Qt.resolvedUrl("ForumDirPage.qml"));
        }
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
        onClicked: view.scrollToTop();
    }

    SilicaFlickable {
        id: view;
        visible: squareData != null;
        anchors { fill: parent; topMargin: viewHeader.height; }
        contentWidth: contentCol.width;
        contentHeight: contentCol.height;
        Column {
            id: contentCol;
            width: view.width;
            PullToActivate {
                myView: view;
                onRefresh: getlist();
            }
            PathView {
                id: banner;
                width: parent.width;
                height: Math.floor(width / 3.3);
                model: squareData ? squareData.banner : [];
                preferredHighlightBegin: 0.5;
                preferredHighlightEnd: 0.5;
                path: Path {
                    startX: -banner.width*banner.count/2 + banner.width/2;
                    startY: banner.height/2;
                    PathLine {
                        x: banner.width*banner.count/2 + banner.width/2;
                        y: banner.height/2;
                    }
                }
                delegate: bannerDelegate;
                Component {
                    id: bannerDelegate;
                    Item {
                        implicitWidth: banner.width;
                        implicitHeight: banner.height;
                        Image {
                            id: previewImg;
                            anchors.fill: parent;
                            smooth: true;
                            source: utility.percentDecode(modelData.pic_url);
                        }
                        Image {
                            anchors.centerIn: parent;
                            source: previewImg.status === Image.Ready ? "" : "../gfx/photos.svg";
                        }
                        Rectangle {
                            anchors.fill: parent;
                            color: "black";
                            opacity: mouseArea.pressed ? 0.3 : 0;
                        }
                        MouseArea {
                            id: mouseArea;
                            anchors.fill: parent;
                            onClicked: {
                                var link = modelData.link;
                                if (link.indexOf("pb:") === 0){
                                    var prop = { threadId: link.substring(3) };
                                    signalCenter.enterThread(prop);
                                } else if (link.indexOf("opfeature:") === 0){
                                    signalCenter.openBrowser(link.substring(10));
                                } else {
                                    console.log(JSON.stringify(modelData))
                                }
                            }
                        }
                    }
                }
                Timer {
                    running: Qt.application.active && banner.count > 1 && !banner.moving && !view.moving;
                    interval: 3000;
                    repeat: true;
                    onTriggered: banner.incrementCurrentIndex();
                }
            }

            Grid {
                id: flr;
                width: parent.width;
                columns: 2;
                Repeater {
                    model: squareData ? squareData.forum_list_recommend : [];
                    MenuItem {
                        platformInverted: tbsettings.whiteTheme;
                        width: flr.width / 2;
                        text: modelData.title;
                        onClicked: {
                            var link = modelData.link;
                            if (link.indexOf("list:")===0){
                                var prop = { stType: "topBarList|"+index, listId: link.substring(5), title: modelData.title };
                                pageStack.push(Qt.resolvedUrl("SquareListPage.qml"), prop);
                            }
                        }
                        Rectangle {
                            anchors.fill: parent;
                            border { width: 1; color: constant.colorMarginLine; }
                            color: "transparent";
                        }
                    }
                }
            }

            ListHeading {
                id: fbt;
                platformInverted: tbsettings.whiteTheme;
                ListItemText {
                    anchors.fill: parent.paddingItem;
                    platformInverted: parent.platformInverted;
                    text: squareData ? squareData.forum_browse_title||"" : "";
                    role: "Heading";
                }
            }
            Repeater {
                id: fbr;
                model: squareData ? squareData.forum_browse : [];
                ListItem {
                    platformInverted: tbsettings.whiteTheme;
                    subItemIndicator: true;
                    onClicked: {
                        if (modelData.is_all === "1"){
                            pageStack.push(Qt.resolvedUrl("ForumDirPage.qml"));
                        } else {
                            var link = modelData.link;
                            if (link.indexOf("list:")===0){
                                var prop = { stType: "squareItem|"+index, listId: link.substring(5), title: modelData.title };
                                pageStack.push(Qt.resolvedUrl("SquareListPage.qml"), prop);
                            }
                        }
                    }
                    Image {
                        id: fbrPic;
                        anchors {
                            left: parent.paddingItem.left;
                            top: parent.paddingItem.top;
                            bottom: parent.paddingItem.bottom;
                        }
                        width: height;
                        source: modelData.pic_url;
                    }
                    Column {
                        anchors {
                            left: fbrPic.right; leftMargin: constant.paddingLarge;
                            right: parent.paddingItem.right;
                            verticalCenter: parent.verticalCenter;
                        }
                        spacing: constant.paddingSmall;
                        Text {
                            font: constant.titleFont;
                            color: constant.colorLight;
                            text: modelData.title;
                        }
                        Text {
                            width: parent.width;
                            elide: Text.ElideRight;
                            font: constant.subTitleFont;
                            color: constant.colorMid;
                            text: modelData.sub_title;
                        }
                    }
                }
            }
            ListHeading {
                id: tlt;
                platformInverted: tbsettings.whiteTheme;
                ListItemText {
                    anchors.fill: parent.paddingItem;
                    platformInverted: parent.platformInverted;
                    role: "Heading";
                    text: qsTr("Thread recommend");
                }
            }
            ListView {
                id: tlv;
                width: parent.width;
                height: constant.graphicSizeLarge+constant.graphicSizeSmall;
                highlightFollowsCurrentItem: true;
                highlightMoveDuration: 300;
                highlightRangeMode: ListView.StrictlyEnforceRange;
                preferredHighlightBegin: 0;
                preferredHighlightEnd: tlv.width;
                snapMode: ListView.SnapOneItem;
                orientation: ListView.Horizontal;
                model: squareData ? squareData.thread_list : [];
                delegate: tlvDel;
                Component {
                    id: tlvDel;
                    Column {
                        width: tlv.width;
                        AbstractItem {
                            onClicked: {
                                var prop = { title: modelData.title, threadId: modelData.id }
                                signalCenter.enterThread(prop);
                            }
                            Text {
                                id: title;
                                anchors {
                                    left: parent.paddingItem.left;
                                    right: parent.paddingItem.right;
                                    top: parent.top; topMargin: constant.paddingMedium;
                                }
                                elide: Text.ElideRight;
                                font: constant.titleFont;
                                color: constant.colorLight;
                                text: modelData.title;
                            }
                            Text {
                                anchors {
                                    left: parent.paddingItem.left;
                                    right: parent.paddingItem.right;
                                    top: title.bottom; topMargin: constant.paddingSmall;
                                }
                                elide: Text.ElideRight;
                                color: constant.colorMid;
                                font: constant.subTitleFont;
                                text: Script.BaiduParser.__parseRawText(modelData.abstract);
                            }
                        }
                        Item {
                            width: parent.width;
                            height: constant.graphicSizeSmall;
                            Text {
                                anchors {
                                    left: parent.left; leftMargin: constant.paddingLarge;
                                    verticalCenter: parent.verticalCenter;
                                }
                                font: constant.subTitleFont;
                                color: constant.colorMid;
                                text: modelData.forum_name;
                            }
                            Row {
                                anchors {
                                    right: parent.right; rightMargin: constant.paddingLarge;
                                    verticalCenter: parent.verticalCenter;
                                }
                                Image {
                                    asynchronous: true;
                                    source: "../gfx/btn_icon_comment_n"+constant.invertedString+".png";
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter;
                                    text: modelData.reply_num;
                                    font: constant.subTitleFont;
                                    color: constant.colorMid;
                                }
                            }
                        }
                    }
                }
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter;
                spacing: constant.paddingLarge;
                Repeater {
                    model: tlv.count;
                    Rectangle {
                        width: constant.paddingMedium;
                        height: width;
                        radius: width / 2;
                        border { width: 1; color: constant.colorMarginLine; }
                        color: index === tlv.currentIndex ? "#1080dd" : "transparent";
                    }
                }
            }
            Item { width: 1; height: constant.paddingMedium; }
        }
    }

    Component.onCompleted: getlist();

    // For keypad
    onStatusChanged: {
        if (status === PageStatus.Active){
            view.forceActiveFocus();
        }
    }
}
