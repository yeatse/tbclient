import QtQuick 1.0
import com.nokia.symbian 1.0
import "../Component"
import "../Silica"
import "../../js/main.js" as Script

MyPage {
    id: page;

    property string uid;
    property string type;
    onUidChanged: internal.getlist();

    tools: ToolBarLayout {
        BackButton {}
        ToolButtonWithTip {
            toolTipText: qsTr("Refresh");
            iconSource: "toolbar-refresh";
            onClicked: internal.getlist();
        }
    }

    QtObject {
        id: internal;

        property int currentPage: 1;
        property bool hasMore: false;
        property int totalCount: 0;

        function getlist(option){
            option = option||"renew";
            var opt = {
                page: internal,
                model: view.model,
                uid: uid,
                type: type
            }
            if (option === "renew"){
                opt.pn = 1;
                opt.renew = true;
            } else {
                opt.pn = currentPage + 1;
            }
            var s = function(){ loading = false; }
            var f = function(err){ loading = false; signalCenter.showMessage(err); }
            loading = true;
            Script.getUserPage(opt, s, f);
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
        model: ListModel {}
        delegate: friendDelegate;
        header: PullToActivate {
            myView: view;
            onRefresh: internal.getlist();
        }
        footer: FooterItem {
            visible: view.count > 0;
            enabled: !loading && internal.hasMore;
            onClicked: internal.getlist("next");
        }

        Component {
            id: friendDelegate
            AbstractItem {
                id: root;
                onClicked: signalCenter.linkClicked("at:"+model.id);

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
                        right: chatBtn.left; rightMargin: constant.paddingMedium;
                        verticalCenter: parent.verticalCenter;
                    }
                    spacing: constant.paddingSmall;
                    Text {
                        font: constant.titleFont;
                        color: constant.colorLight;
                        text: name_show;
                    }
                    Text {
                        width: parent.width;
                        elide: Text.ElideRight;
                        textFormat: Text.PlainText;
                        font: constant.subTitleFont;
                        color: constant.colorMid;
                        text: intro;
                    }
                }

                Image {
                    id: chatBtn;
                    anchors {
                        right: root.paddingItem.right;
                        verticalCenter: parent.verticalCenter;
                    }
                    source: "../gfx/instant_messenger_chat.svg";
                    opacity: chatBtnMa.pressed ? 0.7 : 1;
                    MouseArea {
                        id: chatBtnMa;
                        anchors.fill: parent;
                        onClicked: {
                            var prop = { chatName: name_show, chatId: model.id }
                            pageStack.push(Qt.resolvedUrl("../Message/ChatPage.qml"), prop);
                        }
                    }
                }
            }
        }
    }

    ScrollDecorator {
        flickableItem: view; //platformInverted: tbsettings.whiteTheme;
    }

    // For keypad
    onStatusChanged: {
        if (status === PageStatus.Active){
            view.forceActiveFocus();
        }
    }
    Keys.onPressed: {
        switch (event.key){
        case Qt.Key_R: internal.getlist(); event.accepted = true; break;
        }
    }
}
