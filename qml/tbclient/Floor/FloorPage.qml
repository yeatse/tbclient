import QtQuick 1.1
import com.nokia.symbian 1.1
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

    tools: ToolBarLayout {
        BackButton {}
        ToolButtonWithTip {
            toolTipText: qsTr("Refresh");
            iconSource: "toolbar-refresh";
            onClicked: internal.getlist();
        }
        ToolButtonWithTip {
            toolTipText: qsTr("Reply");
            enabled: internal.post != null;
            iconSource: "../../gfx/edit"+constant.invertedString+".svg";
            onClicked: toolsArea.state = "Input";
        }
        ToolButtonWithTip {
            toolTipText: qsTr("Menu");
            iconSource: "toolbar-menu";
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
            } else {
                opt.pn = currentPage + 1;
            }
            loading = true;
            function s(){ loading = false; }
            function f(err){ signalCenter.showMessage(err); loading = false; }
            Script.getFloorPage(opt, s ,f);
        }
        function openMenu(){
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
                    signalCenter.needVCodeNew(page, obj.info.vcode_md5, obj.info.vcode_pic_url);
                }
            }
            Script.floorReply(opt, s, f);
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
            top: viewHeader.bottom;
        }
        height: screen.height - privateStyle.statusBarHeight - viewHeader.height - toolsArea.height;
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

    ScrollDecorator { flickableItem: view; platformInverted: tbsettings.whiteTheme; }

    ToolsArea {
        id: toolsArea;
    }

    // For keypad
    onStatusChanged: {
        if (status === PageStatus.Active){
            view.forceActiveFocus();
        } else if (status === PageStatus.Deactivating){
            audioWrapper.stop();
            toolsArea.state = "";
        }
    }

    Keys.onPressed: {
        switch (event.key){
        case Qt.Key_M: internal.openMenu(); event.accepted = true; break;
        case Qt.Key_R: internal.getlist(); event.accepted = true; break;
        case Qt.Key_E: if (internal.post)toolsArea.state = "Input"; event.accepted = true; break;
        }
    }
}
