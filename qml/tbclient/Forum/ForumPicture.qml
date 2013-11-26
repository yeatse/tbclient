import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"
import "../Silica"
import "../../js/main.js" as Script

MyPage {
    id: page;

    property string name;
    onNameChanged: getlist();

    property variant forum: null;
    property bool hasMore: false;

    property int batchStart: 1;
    property int batchEnd: 240;
    property int cursor: 0;

    property variant photolist: [];

    orientationLock: PageOrientation.LockPortrait;

    title: forum?forum.name:name;

    tools: ToolBarLayout {
        BackButton {}
        ToolButtonWithTip {
            toolTipText: qsTr("Refresh");
            iconSource: "toolbar-refresh";
            onClicked: getlist();
        }
        ToolButtonWithTip {
            toolTipText: qsTr("Create a thread");
            iconSource: "../../gfx/edit"+constant.invertedString+".svg";
        }
        ToolButtonWithTip {
            toolTipText: qsTr("Menu");
            iconSource: "toolbar-menu";
        }
    }

    function getlist(option){
        option = option || "renew";
        var opt = {
            kw: forum?forum.name:name,
            model1: listModel1,
            model2: listModel2,
            page: page
        };
        function s(){ loading = false; view.finished(); }
        function f(err){ loading = false; signalCenter.showMessage(err); }
        loading = true;
        if (option == "renew"){
            page.hasMore = false;
            batchStart = 1;
            batchEnd = 240;
            photolist = [];
            opt.bs = batchStart;
            opt.be = batchEnd;
            opt.renew = true;
            Script.getPhotoPage(opt, s, f);
        } else if (option == "next"){
            if (cursor < photolist.length){
                var list = photolist.slice(cursor, cursor+30);
                opt.ids = list;
                Script.getPhotoList(opt, s, f);
            } else if (hasMore){
                opt.bs = batchEnd+1;
                opt.be = batchEnd+240;
                opt.renew = true;
                Script.getPhotoPage(opt, s, f);
            }
        } else if (option == "prev"){
            if (batchStart > 240){
                opt.bs = batchStart - 240;
                opt.be = batchStart - 1;
            } else {
                opt.bs = 1;
                opt.be = 240;
            }
            opt.renew = true;
            Script.getPhotoPage(opt, s, f);
        }
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
        onClicked: view.scrollToTop();
    }

    SilicaFlickable {
        id: view;

        signal finished;

        anchors { fill: parent; topMargin: viewHeader.height; }
        contentWidth: parent.width;
        contentHeight: contentCol.height;

        Column {
            id: contentCol;
            anchors { left: parent.left; right: parent.right; }
            FooterItem {
                visible: batchStart > 240;
                enabled: !loading;
                onClicked: getlist("prev");
            }
            Row {
                anchors { left: parent.left; right: parent.right; }
                Column {
                    width: parent.width / 2;
                    Repeater {
                        model: ListModel { id: listModel1; property int cursor: 0; }
                        ForumPictureDelegate {}
                    }
                }
                Column {
                    width: parent.width / 2;
                    Repeater {
                        model: ListModel { id: listModel2; property int cursor: 0; }
                        ForumPictureDelegate {}
                    }
                }
            }
            FooterItem {
                visible: cursor < photolist.length || hasMore;
                enabled: !loading;
                onClicked: getlist("next");
            }
        }
    }

    ScrollDecorator { flickableItem: view; platformInverted: tbsettings.whiteTheme; }

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
        case Qt.Key_M: openMenu(); event.accepted = true; break;
        case Qt.Key_R: getlist(); event.accepted = true; break;
        case Qt.Key_Up: view.contentY = Math.max(0, view.contentY-view.height); break;
        case Qt.Key_Down: view.contentY = Math.min(view.contentHeight-view.height, view.contentY+view.height); break;
        }
    }
}
