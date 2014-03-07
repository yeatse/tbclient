import QtQuick 1.1
import com.nokia.symbian 1.1
import "../../js/main.js" as Script
import "../Component"

MyPage {
    id: page;

    property string threadId;
    property variant thread: null;
    property variant forum: null;
    property variant user: null;

    property int currentPage: 0;
    property int totalPage: 0;
    property bool hasMore: false;
    property bool hasPrev: false;
    property int bottomPage: 0;
    property int topPage: 0;

    property bool isReverse: false;
    property bool isLz: false;
    property bool isArround: false;

    property bool fromBookmark: false;
    property bool isCollected: false;
    property string collectMarkPid;

    property variant threadMenu: null;

    property int privateFullPage: 0;
    onIsLzChanged: {
        if (isLz) privateFullPage = totalPage;
        else totalPage = privateFullPage;
    }

    function positionAtTop(){
        internal.openContextMenu();
    }
    function focus(){
        view.forceActiveFocus();
    }

    function getlist(option){
        option = option||"renew";
        var opt = {
            kz: threadId,
            model: view.model
        }
        if (isReverse) opt.r = 1;
        if (isLz) opt.lz = 1;
        if (option === "renew"){
            isArround = false;
            opt.renew = true;
            if (isReverse) opt.pn = totalPage;
        } else if (option === "next"){
            if (isReverse && bottomPage == 1 && !isArround){
                signalCenter.showMessage(qsTr("First page now"));
                return;
            }
            if (isArround){
                opt.arround = true;
                opt.pid = view.model.get(view.count-1).id;
            } else {
                if (hasMore)
                    opt.pn = isReverse ? bottomPage - 1
                                       : bottomPage + 1;
                else {
                    opt.pn = bottomPage;
                    opt.dirty = true;
                }
            }
        } else if (option === "prev"){
            if (!isReverse && topPage == 1 && !isArround){
                getlist("renew");
                return;
            }
            opt.insert = true;
            if (isArround){
                opt.arround = true;
                opt.r = 1;
                opt.pid = view.model.get(0).id;
            } else {
                if (hasPrev)
                    opt.pn = isReverse ? topPage + 1
                                       : topPage - 1;
                else {
                    opt.pn = topPage;
                    opt.dirty = true;
                }
            }
        } else if (option === "jump"){
            isArround = false;
            opt.renew = true;
            opt.pn = currentPage;
        } else if (/\b\d+\b/.test(option)){
            isArround = true;
            opt.renew = true;
            opt.arround = true;
            opt.pid = option;
        }

        if (fromBookmark && isArround)
            opt.st_type = "store_thread";

        var s = function(obj, modelAffected){
            loading = false;
            user = obj.user;
            thread = obj.thread;
            forum = obj.forum;
            currentPage = obj.page.current_page;
            totalPage = obj.page.total_page;
            isCollected = obj.thread.collect_status !== "0";
            collectMarkPid = obj.thread.collect_mark_pid;

            if (option === "renew"||option === "jump"||/\b\d+\b/.test(option)){
                hasMore = obj.page.has_more === "1";
                hasPrev = obj.page.has_prev === "1";
                bottomPage = currentPage;
                topPage = currentPage;
            } else if (option === "next"){
                hasMore = obj.page.has_more === "1";
                bottomPage = currentPage;
            } else if (option === "prev"){
                hasPrev = obj.page.has_prev === "1";
                topPage = currentPage;
                view.positionViewAtIndex(modelAffected, ListView.Visible);
            }
            if (modelAffected === 0)
                signalCenter.showMessage(qsTr("No more posts"));
        }
        var f = function(err){
            loading = false;
            signalCenter.showMessage(err);
        }
        loading = true;
        Script.getThreadPage(opt, s, f);
    }

    function addStore(pid){
        var opt = { add: true, tid: threadId }
        opt.status = isLz ? "1" : isReverse ? "2" : "0";
        opt.pid = pid || view.model.get(0).id;
        var s = function(){ loading = false; isCollected = true;
            collectMarkPid = opt.pid; signalCenter.showMessage(qsTr("Success")) }
        var f = function(err){ loading = false; signalCenter.showMessage(err); }
        loading = true;
        Script.setBookmark(opt, s, f);
    }
    function rmStore(){
        var opt = { add: false, tid: threadId }
        var s = function(){ loading = false; isCollected = false;
            collectMarkPid = ""; signalCenter.showMessage(qsTr("Success")) }
        var f = function(err){ loading = false; signalCenter.showMessage(err); }
        loading = true;
        Script.setBookmark(opt, s, f);
    }
    function createMenu(index){
        if (!threadMenu)
            threadMenu = Qt.createComponent("ThreadMenu.qml").createObject(page);
        threadMenu.index = index;
        threadMenu.model = view.model.get(index);
        threadMenu.open();
    }

    function delPost(index){
        var model = view.model.get(index);
        var execute;
        if (model.floor === "1"){
            // delthread
            execute = function(){
                        var opt = {
                            word: forum.name,
                            fid: forum.id,
                            tid: thread.id
                        }
                        loading = true;
                        var s = function(){
                            loading = false;
                            signalCenter.showMessage(qsTr("Success"));
                            // in ThreadPage
                            internal.removeThreadPage(page);
                        }
                        var f = function(err){
                            loading = false;
                            signalCenter.showMessage(err);
                        }
                        Script.delthread(opt, s, f);
                    }
            signalCenter.createQueryDialog(qsTr("Warning"),
                                           qsTr("Delete this thread?"),
                                           qsTr("OK"),
                                           qsTr("Cancel"),
                                           execute);
        } else {
            // delpost
            execute = function(){
                        var opt = {
                            floor: false,
                            vip: user.is_manager === "0",
                            word: forum.name,
                            fid: forum.id,
                            tid: thread.id,
                            pid: model.id
                        }
                        loading = true;
                        var s = function(){
                            loading = false;
                            signalCenter.showMessage(qsTr("Success"));
                            view.model.remove(index);
                        }
                        var f = function(err){
                            loading = false;
                            signalCenter.showMessage(err);
                        }
                        Script.delpost(opt, s, f);
                    }
            signalCenter.createQueryDialog(qsTr("Warning"),
                                           qsTr("Delete this post?"),
                                           qsTr("OK"),
                                           qsTr("Cancel"),
                                           execute);
        }
    }

    title: thread ? thread.title : qsTr("New tab");

    ListView {
        id: view;
        anchors.fill: parent;
        cacheBuffer: 600;
        model: ListModel {}
        delegate: ThreadDelegate {
            onClicked: floor === "1"
                       ? pressAndHold()
                       : signalCenter.enterFloor(thread.id, model.id, undefined, user.is_manager);
            onPressAndHold: createMenu(index);
        }
        footer: FooterItem {
            visible: view.count > 0;
            enabled: !loading;
            onClicked: getlist("next");
        }
        header: ThreadHeader {
            PullToActivate {
                myView: view;
                enabled: !loading;
                onRefresh: getlist("prev");
            }
            visible: thread != null;
        }
    }

    ScrollDecorator {
        flickableItem: view;
        platformInverted: tbsettings.whiteTheme;
    }

    Column {
        id: btnCol;
        anchors {
            right: parent.right; rightMargin: constant.paddingSmall;
            verticalCenter: view.verticalCenter;
        }
        spacing: constant.paddingLarge;
        Image {
            source: "../gfx/icon_arrow.png";
            opacity: upMA.pressed ? 0.7 : 0.3;
            Behavior on opacity { NumberAnimation { duration: 50; } }
            MouseArea {
                id: upMA;
                anchors.fill: parent;
                onClicked: {
                    view.contentY -= view.height;
                    if (view.atYBeginning) view.positionViewAtBeginning();
                }
                onPressAndHold: view.positionViewAtBeginning();
            }
        }
        Image {
            source: "../gfx/icon_arrow.png";
            rotation: 180;
            opacity: downMA.pressed ? 0.7 : 0.3;
            Behavior on opacity { NumberAnimation { duration: 50; } }
            MouseArea {
                id: downMA;
                anchors.fill: parent;
                onClicked: {
                    view.contentY += view.height;
                    if (view.atYEnd) view.positionViewAtEnd();
                }
                onPressAndHold: view.positionViewAtEnd();
            }
        }
    }
}
