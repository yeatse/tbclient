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
    onPostIdChanged: internal.getlist();

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
            var opt = {
                page: internal, model: view.model, kz: threadId, pid: postId
            }
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
        if (status === PageStatus.Activating){
            app.showToolBar = false;
        } else if (status === PageStatus.Deactivating){
            app.showToolBar = true;
        } else if (status === PageStatus.Active){
            view.forceActiveFocus();
        }
    }

    Keys.onPressed: {
        switch (event.key){
        case Qt.Key_M: internal.openMenu(); event.accepted = true; break;
        case Qt.Key_R: internal.getlist(); event.accepted = true; break;
        case Qt.Key_E: toolsArea.state = "Input"; event.accepted = true; break;
        }
    }
}
