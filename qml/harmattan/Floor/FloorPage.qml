import QtQuick 1.1
import com.nokia.meego 1.1
import "../Component"
import "../Silica"
import "../../js/main.js" as Script

MyPage {
    id: page;

    title: qsTr("Subfloor");

    property string threadId;
    property string postId;
    property string spostId;
    onPostIdChanged: internal.getlist();
    onSpostIdChanged: internal.getlist();

    // 0 -- normal, 1 -- major, 2 -- minor
    property int managerGroup: 0;

    tools: ToolBarLayout {
        BackButton {}
        ToolIcon {
            platformIconId: "toolbar-refresh"
            onClicked: internal.getlist();
        }
        ToolIcon {
            enabled: internal.post != null;
            platformIconId: "toolbar-edit";
            onClicked: toolsArea.state = "Input";
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu";
            onClicked: internal.openMenu();
        }
    }

    Connections {
        target: signalCenter;
        onVcodeSent: if (caller === page) internal.addPost(vcode, vcodeMd5);
    }

    QtObject {
        id: internal;

        property variant forum: ({});
        property variant thread: ({});
        property variant post: null;
        property variant menu: null;
        property variant jumper: null;
        property variant floorMenu: null;

        property int currentPage: 1;
        property int pageSize: 10;
        property int totalPage: 0;
        property int totalCount: 0;

        function getlist(option){
            option = option || "renew";
            var opt = { page: internal, model: view.model, kz: threadId }

            if (post != null) opt.pid = post.id;
            else if (postId != "") opt.pid = postId;
            else if (spostId != "") opt.spid = spostId;

            if (option === "renew"){
                opt.renew = true;
                opt.pn = 1;
            } else if (option === "next"){
                opt.pn = currentPage + 1;
            } else if (option === "jump"){
                opt.renew = true;
                opt.pn = currentPage;
            }
            loading = true;
            var s = function(){ loading = false; }
            var f = function(err){ signalCenter.showMessage(err); loading = false; }
            Script.getFloorPage(opt, s ,f);
        }
        function openMenu(){
            if (menu == null)
                menu = menuComp.createObject(page);
            menu.open();
        }
        function jumpToPage(){
            if (!jumper){
                jumper = Qt.createComponent("../Dialog/PageJumper.qml").createObject(page);
                var jump = function(){
                    currentPage = jumper.currentPage;
                    getlist("jump");
                }
                jumper.accepted.connect(jump);
            }
            jumper.totalPage = totalPage;
            jumper.currentPage = currentPage;
            jumper.open();
        }

        function addPost(vcode, vcodeMd5){
            var opt = {
                tid: thread.id,
                fid: forum.id,
                quote_id: post.id,
                content: toolsArea.text,
                kw: forum.name
            }
            if (vcode){
                opt.vcode = vcode;
                opt.vcode_md5 = vcodeMd5;
            }
            loading = true;
            var s = function(){
                loading = false;
                signalCenter.showMessage(qsTr("Success"));
                getlist();
                toolsArea.text = "";
                toolsArea.state = "";
            }
            var f = function(err, obj){
                loading = false;
                signalCenter.showMessage(err);
                if (obj && obj.info && obj.info.need_vcode === "1"){
                    signalCenter.needVCode(page, obj.info.vcode_md5, obj.info.vcode_pic_url,
                                           obj.info.vcode_type === "4");
                }
            }
            Script.floorReply(opt, s, f);
        }

        function addStore(){
            var opt = { add: true, tid: threadId }
            opt.pid = post.id;
            var s = function(){ loading = false; signalCenter.showMessage(qsTr("Success")) }
            var f = function(err){ loading = false; signalCenter.showMessage(err); }
            loading = true;
            Script.setBookmark(opt, s, f);
        }

        function createMenu(index){
            if (!floorMenu)
                floorMenu = Qt.createComponent("FloorMenu.qml").createObject(page);
            floorMenu.index = index;
            floorMenu.model = view.model.get(index);
            floorMenu.open();
        }

        function delPost(index){
            var execute = function(){
                var model = view.model.get(index);
                var opt = {
                    floor: true,
                    vip: managerGroup === 0,
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

    Component {
        id: menuComp;
        Menu {
            id: menu;
            MenuLayout {
                MenuItem {
                    text: qsTr("Add to bookmark");
                    onClicked: internal.addStore();
                }
                MenuItem {
                    text: qsTr("Jump to page");
                    onClicked: internal.jumpToPage();
                }
                MenuItem {
                    text: qsTr("View original thread");
                    onClicked: signalCenter.enterThread({threadId: internal.thread.id});
                }
            }
        }
    }

    ViewHeader {
        id: viewHeader;
        title: internal.post ? qsTr("Floor %1").arg(internal.post.floor)
                             : page.title;
        onClicked: view.scrollToTop();
    }

    SilicaListView {
        id: view;
        anchors {
            left: parent.left; right: parent.right;
            top: viewHeader.bottom; bottom: toolsArea.top;
        }
        cacheBuffer: height * 3;
        model: ListModel {}
        header: internal.post ? headerComp : null;
        Component {
            id: headerComp;
            FloorHeader {
                post: internal.post;
            }
        }
        delegate: FloorDelegate {
            onPressAndHold: internal.createMenu(index)
            onClicked: {
                toolsArea.text = qsTr("Reply to %1 :").arg(author);
                toolsArea.cursorPosition = toolsArea.text.length;
                toolsArea.state = "Input";
            }
        }
        footer: FooterItem {
            visible: view.count > 0;
            enabled: !loading && internal.currentPage < internal.totalPage;
            onClicked: internal.getlist("next");
        }
    }

    ScrollDecorator { flickableItem: view; }

    ToolsArea {
        id: toolsArea;
    }

    onStatusChanged: {
        if (status === PageStatus.Deactivating){
            audioWrapper.stop();
            toolsArea.state = "";
        }
    }
}
