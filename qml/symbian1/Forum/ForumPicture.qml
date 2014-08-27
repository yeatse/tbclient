import QtQuick 1.0
import com.nokia.symbian 1.0
import "../Component"
import "../Silica"
import "../../js/main.js" as Script

MyPage {
    id: page;

    property string name;
    onNameChanged: internal.getlist();

    orientationLock: PageOrientation.LockPortrait;

    loadingVisible: loading && listModel1.count == 0 && listModel1.count == 0;

    title: internal.getName();

    tools: ToolBarLayout {
        BackButton {}
        ToolButtonWithTip {
            toolTipText: qsTr("Refresh");
            iconSource: "toolbar-refresh";
            onClicked: internal.getlist();
        }
        ToolButtonWithTip {
            id: editBtn;
            toolTipText: qsTr("Create a thread");
            iconSource: "../gfx/edit.svg";
            onClicked: {
                var prop = { caller: internal };
                pageStack.push(Qt.resolvedUrl("../Post/PostPage.qml"), prop);
            }
        }
        ToolButtonWithTip {
            id: listBtn;
            toolTipText: qsTr("Activities");
            iconSource: "toolbar-list";
            onClicked: pageStack.replace(Qt.resolvedUrl("ForumPage.qml"),{name: internal.getName()});
        }
    }

    QtObject {
        id: internal;

        property variant forum: ({});
        property variant photolist: [];

        property int batchStart: 1;
        property int batchEnd: pageSize;
        property int pageSize: 300;
        property bool hasMore: false;
        property int cursor: 0;

        function getName(){
            if (forum && forum.hasOwnProperty("name")){
                return forum.name;
            } else {
                return page.name;
            }
        }

        function getlist(option){
            option = option||"renew";
            var opt = {
                kw: getName(),
                model1: listModel1,
                model2: listModel2,
                page: internal
            };
            function s(){ loading = false; view.finished(); }
            function f(err){ loading = false; signalCenter.showMessage(err); }
            loading = true;
            if (option === "renew"){
                opt.bs = 1;
                opt.be = pageSize;
                opt.renew = true;
                Script.getPhotoPage(opt, s, f);
            } else if (option === "next"){
                if (cursor < photolist.length){
                    var list = photolist.slice(cursor, cursor+30);
                    opt.ids = list;
                    Script.getPhotoList(opt, s, f);
                } else if (hasMore){
                    opt.bs = batchEnd + 1;
                    opt.be = batchEnd + pageSize;
                    opt.renew = true;
                    Script.getPhotoPage(opt, s, f);
                }
            } else if (option === "prev"){
                if (batchStart > pageSize){
                    opt.bs = batchStart - pageSize;
                    opt.be = batchStart - 1;
                } else {
                    opt.bs = 1;
                    opt.be = pageSize;
                }
                opt.renew = true;
                Script.getPhotoPage(opt, s, f);
            }
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
            PullToActivate {
                myView: view;
                enabled: !loading;
                onRefresh: internal.getlist("prev");
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
                visible: listModel1.count + listModel2.count > 0;
                enabled: !loading && (internal.hasMore||internal.cursor<internal.photolist.length)
                onClicked: internal.getlist("next");
            }
        }
    }

    ScrollDecorator {
        flickableItem: view; //platformInverted: tbsettings.whiteTheme;
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
        case Qt.Key_M: listBtn.clicked(); event.accepted = true; break;
        case Qt.Key_R: internal.getlist(); event.accepted = true; break;
        case Qt.Key_E: editBtn.clicked(); event.accepted = true; break;
        case Qt.Key_Up: view.contentY = Math.max(0, view.contentY-view.height); break;
        case Qt.Key_Down: view.contentY = Math.min(view.contentHeight-view.height, view.contentY+view.height); break;
        }
    }
}
