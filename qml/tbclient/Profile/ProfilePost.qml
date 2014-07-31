import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"
import "../Silica"
import "../../js/main.js" as Script

MyPage {
    id: page;

    property string uid;
    onUidChanged: internal.getlist();

    tools: ToolBarLayout {
        BackButton {}
        ToolButtonWithTip {
            toolTipText: qsTr("Refresh");
            iconSource: "toolbar-refresh";
            onClicked: internal.getlist();
        }
    }

    QtObject {
        id: internal;

        property int currentPage: 1;
        property bool hasMore: false;

        function getlist(option){
            option = option||"renew";
            var opt = { page: internal, model: view.model, user_id: uid };
            if (option === "renew"){
                opt.pn = 1;
                opt.renew = true;
            } else if (option === "next"){
                opt.pn = currentPage + 1;
            }
            var s = function(){
                loading = false;
            }
            var f = function(err){
                loading = false;
                if (err === "hide")
                    err = qsTr("His posts are not allowed to view");
                signalCenter.showMessage(err);
            }
            loading = true;
            Script.getMyPost(opt, s, f);
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
        cacheBuffer: view.height * 5;
        model: ListModel {}
        delegate: postDelegate;
        header: PullToActivate {
            myView: view;
            onRefresh: internal.getlist();
        }
        footer: FooterItem {
            visible: view.count > 0;
            enabled: internal.hasMore && !loading;
            onClicked: internal.getlist("next");
        }
        section {
            property: "reply_time";
            delegate: sectionDelegate;
        }

        Component {
            id: sectionDelegate;
            Column {
                width: view.width;
                Row {
                    x: constant.paddingLarge;
                    Image {
                        source: "../gfx/icon_time_node"+constant.invertedString+".png"
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter;
                        text: section;
                        font: constant.subTitleFont;
                        color: constant.colorMid;
                    }
                }
                Rectangle {
                    width: parent.width;
                    height: 1;
                    color: constant.colorMarginLine;
                }
            }
        }

        Component {
            id: postDelegate;
            AbstractItem {
                id: root;

                implicitHeight: contentCol.height + (constant.paddingLarge+constant.paddingMedium)*2;
                onClicked: signalCenter.createEnterThreadDialog(title, is_floor, pid, tid, fname);

                Image {
                    id: icon;
                    anchors {
                        left: root.paddingItem.left; top: root.paddingItem.top;
                    }
                    asynchronous: true;
                    source: "../gfx/icon_thread_node"+constant.invertedString+".png";
                }
                BorderImage {
                    id: background;
                    anchors {
                        left: icon.right; top: root.paddingItem.top;
                        right: root.paddingItem.right; bottom: root.paddingItem.bottom;
                    }
                    border { left: 20; top: 25; right: 10; bottom: 10; }
                    asynchronous: true;
                    source: "../gfx/time_line"+constant.invertedString+".png";
                }
                Column {
                    id: contentCol;
                    anchors {
                        left: background.left; leftMargin: 10 + constant.paddingMedium;
                        right: background.right; rightMargin: 10;
                        top: root.paddingItem.top; topMargin: constant.paddingMedium;
                    }
                    spacing: constant.paddingMedium;
                    Item {
                        width: parent.width;
                        height: childrenRect.height;
                        Text {
                            font: constant.subTitleFont;
                            color: constant.colorMid;
                            text: isReply ? qsTr("Reply at %1").arg(fname) : qsTr("Post at %1").arg(fname);
                        }
                        Text {
                            anchors.right: parent.right;
                            font: constant.subTitleFont;
                            color: constant.colorTextSelection;
                            text: reply_time;
                        }
                    }
                    Text {
                        width: parent.width;
                        wrapMode: Text.Wrap;
                        font: constant.titleFont;
                        color: constant.colorLight;
                        text: title;
                    }
                }
            }
        }
    }

    ScrollDecorator {
        flickableItem: view;
        platformInverted: tbsettings.whiteTheme;
    }

    // For keypad
    Connections {
        target: platformPopupManager;
        onPopupStackDepthChanged: {
            if (platformPopupManager.popupStackDepth === 0
                    && page.status === PageStatus.Active){
                view.forceActiveFocus();
            }
        }
    }
    onStatusChanged: {
        if (status === PageStatus.Active){
            view.forceActiveFocus();
        }
    }

    Keys.onPressed: {
        switch (event.key){
        case Qt.Key_R: internal.getlist(); event.accepted = true; break;
        }
    }
}
