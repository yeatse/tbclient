import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"
import "../Silica"
import "../../js/main.js" as Script

MyPage {
    id: page;

    property string threadId;
    property string postId;
    onPostIdChanged: internal.getlist();

    QtObject {
        id: internal;

        property variant forum: ({});
        property variant thread: ({});
        property variant post: ({});

        property int currentPage: 1;
        property int pageSize: 10;
        property int totalPage: 0;

        function getlist(option){
            option = option || "renew";
            var opt = {
                page: page, model: view.model, kz: threadId, pid: postId
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
    }

    ViewHeader {
        id: viewHeader;
    }

    SilicaListView {
        id: view;
        anchors {
            left: parent.left; right: parent.right;
            top: viewHeader.bottom; bottom: toolsArea.top;
        }
        model: ListModel {}
        header: FloorHeader {

        }
        delegate: FloorDelegate {
        }
    }

    ToolsArea {
        id: toolsArea;
    }

    onStatusChanged: {
        if (status === PageStatus.Activating){
            app.showToolBar = false;
        } else if (status === PageStatus.Deactivating){
            app.showToolBar = true;
        } else if (status === PageStatus.Active){
            view.forceActiveFocus();
        }
    }
}
