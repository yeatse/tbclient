import QtQuick 1.0
import com.nokia.symbian 1.0
import "../Component"
import "../Silica"
import "../../js/main.js" as Script

MyPage {
    id: page;
    title: qsTr("Home page");
    tools: ToolBarLayout {
        BackButton {}
        ToolButtonWithTip {
            toolTipText: qsTr("Refresh");
            iconSource: "toolbar-refresh";
            onClicked: internal.getlist();
        }
        ToolButtonWithTip {
            toolTipText: qsTr("Square");
            iconSource: "../gfx/compass.svg";
            onClicked: pageStack.push(Qt.resolvedUrl("SquarePage.qml"));
        }
    }

    QtObject {
        id: internal;

        property bool hasMore: false;
        property int currentPage: 1;
        property int total: 0;

        function getlist(option){
            option = option||"renew";
            var opt = {
                page: internal,
                model: view.model
            }
            if (option === "renew"){
                opt.pn = 1;
                opt.renew = true;
            } else {
                opt.pn = currentPage + 1;
            }
            loading = true;
            var s = function(){ loading = false; }
            var f = function(err){ loading = false; signalCenter.showMessage(err); }
            Script.getForumFeed(opt, s, f);
        }
    }

    ViewHeader {
        id: viewHeader;
        Image {
            anchors.centerIn: parent;
            sourceSize.height: parent.height - constant.paddingSmall;
            source: "../gfx/logo_teiba_top.png"
        }
        onClicked: view.scrollToTop();
    }
    SilicaListView {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        cacheBuffer: 0//height * 5;
        model: ListModel {}
        delegate: FeedDelegate {
        }
        header: PullToActivate {
            myView: view;
            onRefresh: internal.getlist();
        }
        footer: FooterItem {
            visible: view.count > 0;
            enabled: internal.hasMore && !loading;
            onClicked: internal.getlist("next");
        }
    }

    ScrollDecorator {
        flickableItem: view; //platformInverted: tbsettings.whiteTheme;
    }

    // For keypad
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

    Component.onCompleted: internal.getlist();
}
