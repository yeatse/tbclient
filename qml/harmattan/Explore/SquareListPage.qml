import QtQuick 1.1
import com.nokia.meego 1.1
import "../Component"
import "../Silica"
import "../../js/main.js" as Script

MyPage {
    id: page;

    property string listId;
    property string stType;
    onListIdChanged: internal.getlist();

    tools: ToolBarLayout {
        BackButton {}
    }

    QtObject {
        id: internal;

        property int offset: 0;
        property bool hasMore: false;

        function getlist(option){
            option = option||"renew";
            var opt = {
                list_id: listId,
                st_type: stType,
                model: view.model,
                page: internal
            }
            if (option === "renew"){
                opt.renew = true;
                opt.offset = 0;
            } else {
                opt.offset = offset;
            }
            var s = function(title){
                loading = false; viewHeader.title = title;
            }
            var f = function(err){
                loading = false; signalCenter.showMessage(err);
            }
            loading = true;
            Script.getForumSquareList(opt, s, f);
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
        cacheBuffer: view.height * 3;
        model: ListModel {}
        delegate: ForumRankDelegate {}
        header: PullToActivate {
            myView: view;
            onRefresh: internal.getlist();
        }
        footer: FooterItem {
            visible: view.count > 0;
            enabled: !loading && internal.hasMore;
            onClicked: internal.getlist("next");
        }
    }

    ScrollDecorator { flickableItem: view; }
}
