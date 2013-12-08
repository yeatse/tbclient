import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"
import "../Silica"
import "../../js/main.js" as Script

MyPage {
    id: page;

    title: qsTr("Private letters");

    function focus(){
        view.forceActiveFocus();
    }
    function positionAtTop(){
        view.scrollToTop();
    }

    function takeToForeground(){
        if (infoCenter.pletter > 0){
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
            infoCenter.clear("pletter");
            opt.renew = true;
            opt.pn = 1;
        } else {
            opt.pn = currentPage + 1;
        }
        loading = true;
        function s(){ loading = false; }
        function f(err){ signalCenter.showMessage(err); loading = false; }
        Script.getComlist(opt, s, f);
    }

    function loadFromCache(){
        try {
            var obj = JSON.parse(utility.getUserData("pletter"));
            page.hasMore = obj.has_more === "1";
            page.currentPage = 1;
            Script.BaiduParser.loadComlist({renew: true, model: view.model}, obj.record);
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
                height: constant.graphicSizeLarge+constant.paddingLarge*2;
                Image {
                    id: avatar;
                    anchors {
                        left: root.paddingItem.left;
                        top: root.paddingItem.top;
                        bottom: root.paddingItem.bottom;
                    }
                    width: height;
                    source: portrait;
                }
                Column {
                    anchors {
                        left: avatar.right; leftMargin: constant.paddingMedium;
                        right: root.paddingItem.right; top: root.paddingItem.top;
                    }
                    Text {
                        font: constant.titleFont;
                        color: constant.colorLight;
                        text: name_show;
                    }
                    Text {
                        width: parent.width;
                        wrapMode: Text.WrapAnywhere;
                        maximumLineCount: 2;
                        elide: Text.ElideRight;
                        text: model.text;
                        color: constant.colorMid;
                        font: constant.labelFont;
                    }
                }
                Text {
                    anchors {
                        right: root.paddingItem.right;
                        top: root.paddingItem.top;
                    }
                    font: constant.subTitleFont;
                    color: constant.colorMid;
                    text: time;
                }
            }
        }
    }
    ScrollDecorator { flickableItem: view; platformInverted: tbsettings.whiteTheme; }
}
