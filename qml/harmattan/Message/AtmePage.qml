import QtQuick 1.1
import com.nokia.meego 1.1
import "../Component"
import "../Silica"
import "../../js/main.js" as Script

MyPage {
    id: page;

    title: qsTr("At me");

    function positionAtTop(){
        view.scrollToTop();
    }

    function takeToForeground(){
        view.forceActiveFocus();
        if (infoCenter.atme > 0){
            firstStart = false;
            getlist();
        } else if (firstStart){
            firstStart = false;
            if (!loadFromCache()){
                getlist();
            }
        }
    }

    function getlist(option){
        option = option||"renew";
        var opt = { page: page, model: view.model };
        if (option === "renew"){
            infoCenter.clear("atme");
            opt.renew = true;
            opt.pn = 1;
        } else {
            opt.pn = currentPage + 1;
        }
        loading = true;
        function s(){ loading = false; }
        function f(err){ signalCenter.showMessage(err); loading = false; }
        Script.getAtme(opt, s, f);
    }

    function loadFromCache(){
        try {
            var obj = JSON.parse(utility.getUserData("atme"));
            page.hasMore = obj.page.has_more === "1";
            page.currentPage = obj.page.current_page;
            Script.BaiduParser.loadAtme({model: view.model, renew: true},obj.at_list);
            return true;
        } catch(e){
            return false;
        }
    }

    property int currentPage: 1;
    property bool hasMore: false;
    property bool firstStart: true;

    SilicaListView {
        id: view;
        anchors.fill: parent;
        model: ListModel {}
        delegate: delegateComp;
        header: PullToActivate {
            myView: view;
            onRefresh: getlist();
        }
        footer: FooterItem {
            visible: view.count > 0;
            enabled: hasMore && !loading;
            onClicked: getlist("next");
        }
        Component {
            id: delegateComp;
            AbstractItem {
                id: root;
                implicitHeight: contentCol.height + constant.paddingLarge*2;
                onClicked: signalCenter.createEnterThreadDialog(title, is_floor, post_id, thread_id, fname);
                Image {
                    id: avatar;
                    asynchronous: true;
                    anchors.left: root.paddingItem.left;
                    anchors.top: root.paddingItem.top;
                    width: constant.graphicSizeMedium;
                    height: constant.graphicSizeMedium;
                    source: portrait;
                }
                Column {
                    id: contentCol;
                    anchors {
                        left: avatar.right; leftMargin: constant.paddingMedium;
                        right: root.paddingItem.right;
                        top: root.paddingItem.top;
                    }
                    spacing: constant.paddingSmall;
                    Text {
                        text: replyer;
                        font: constant.titleFont;
                        color: constant.colorLight;
                    }
                    Text {
                        width: parent.width;
                        wrapMode: Text.Wrap;
                        text: content;
                        font: constant.labelFont;
                        color: constant.colorLight;
                    }
                    Text {
                        text: time;
                        font: constant.subTitleFont;
                        color: constant.colorMid;
                    }
                }
            }
        }
    }

    ScrollDecorator { flickableItem: view; }
}
