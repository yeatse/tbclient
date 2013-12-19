import QtQuick 1.1
import com.nokia.symbian 1.1
import "../../js/main.js" as Script
import "../Component"
import "../Silica"

MyPage {
    id: page;

    property string threadId;
    property variant thread: null;
    property variant forum: null;

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

    title: thread ? thread.title : qsTr("New tab");

    SilicaListView {
        id: view;
        anchors.fill: parent;
        cacheBuffer: view.height*5;
        model: ListModel {}
        delegate: ThreadDelegate {
            onClicked: signalCenter.enterFloor(thread.id, model.id);
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
}
