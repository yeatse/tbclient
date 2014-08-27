import QtQuick 1.0
import com.nokia.symbian 1.0
import "../Component"
import "../Silica"
import "../../js/main.js" as Script

MyPage {
    id: page;

    title: qsTr("Reply me");

    function positionAtTop(){
        view.scrollToTop();
    }

    function takeToForeground(){
        view.forceActiveFocus();
        if (infoCenter.replyme > 0){
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
            infoCenter.clear("replyme");
            opt.renew = true;
            opt.pn = 1;
        } else {
            opt.pn = currentPage + 1;
        }
        loading = true;
        function s(){ loading = false; }
        function f(err){ signalCenter.showMessage(err); loading = false; }
        Script.getReplyme(opt, s, f);
    }

    function loadFromCache(){
        try {
            var obj = JSON.parse(utility.getUserData("replyme"));
            page.hasMore = obj.page.has_more === "1";
            page.currentPage = obj.page.current_page;
            Script.BaiduParser.loadReplyme({model: view.model, renew: true}, obj.reply_list);
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
                    anchors {
                        left: root.paddingItem.left;
                        top: root.paddingItem.top;
                    }
                    asynchronous: true;
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
                        color: constant.colorLight;
                        font: constant.titleFont;
                    }
                    Text {
                        width: parent.width;
                        text: content;
                        wrapMode: Text.Wrap;
                        textFormat: Text.PlainText;
                        font: constant.labelFont;
                        color: constant.colorLight;
                    }
                    Item {
                        width: parent.width;
                        height: label.height+constant.paddingMedium*2+5;
                        BorderImage {
                            asynchronous: true;
                            anchors.fill: parent;
                            source: "../gfx/retweet_bg.png";
                            border { left: 32; right: 10; top: 15; bottom: 10; }
                        }
                        Text {
                            id: label;
                            anchors {
                                left: parent.left; leftMargin: constant.paddingMedium;
                                top: parent.top; topMargin: constant.paddingMedium+5;
                                right: parent.right; rightMargin: constant.paddingMedium;
                            }
                            text: quoteMe ? qsTr("Post")+":"+quote_content
                                          : qsTr("Thread")+":"+title;
                            elide: Text.ElideRight;
                            textFormat: Text.PlainText;
                            font: constant.labelFont;
                            color: constant.colorMid;
                        }
                    }
                    Text {
                        color: constant.colorMid;
                        font: constant.subTitleFont;
                        text: qsTr("From %1").arg(fname)+"  "+time;
                    }
                }
            }
        }
    }
    ScrollDecorator {
        flickableItem: view; //platformInverted: tbsettings.whiteTheme;
    }
}
