import QtQuick 1.1
import com.nokia.meego 1.1
import "../Component"
import "../Silica"
import "../Floor" as Floor
import "../../js/main.js" as Script

MyPage {
    id: page;

    property string chatId;
    property string chatName;
    onChatIdChanged: heartBeater.restart();

    title: qsTr("Private letters");

    tools: ToolBarLayout {
        BackButton {}
        ToolIcon {
            platformIconId: "toolbar-edit";
            onClicked: toolsArea.state = "Input";
        }
        ToolIcon {
            platformIconId: "toolbar-delete";
            onClicked: internal.clearMsg();
        }
    }

    QtObject {
        id: internal;

        property bool hasMore: false;

        function getlist(option){
            option = option || "next";
            var opt = {
                page: internal,
                model: view.model,
                com_id: chatId,
                history: option === "prev"
            }
            if (view.count === 0||option === "renew"){
                opt.msg_id = "0";
                opt.renew = true;
            } else if (option === "next"){
                opt.msg_id = view.model.get(view.count-1).msg_id;
            } else if (option === "prev"){
                opt.msg_id = view.model.get(0).msg_id;
            }
            loading = true;
            var s = function(){ loading = false;
                // A hackish line to force the ChatList to refresh
                infoCenter.pletter = 1; }
            var f = function(err){ loading = false; signalCenter.showMessage(err); }
            Script.getChatMsg(opt, s, f);
        }

        function addPost(){
            var opt = {
                com_id: chatId,
                content: toolsArea.text
            }
            loading = true;
            var s = function(){
                loading = false;
                toolsArea.text = "";
                toolsArea.state = "";
                heartBeater.restart();
            }
            var f = function(err){
                loading = false;
                signalCenter.showMessage(err);
            }
            Script.addChatMsg(opt, s, f);
        }

        function clearMsg(){
            var execute = function(){
                loading = true;
                var s = function(){ loading = false; view.model.clear();
                    signalCenter.showMessage(qsTr("Success"))};
                var f = function(err){ loading = false;
                    signalCenter.showMessage(err)};
                var opt = { com_id: chatId, clear: true }
                Script.deleteChatMsg(opt, s, f);
            }
            signalCenter.createQueryDialog(qsTr("Warning"),
                                           qsTr("Clear chat history?"),
                                           qsTr("OK"),
                                           qsTr("Cancel"),
                                           execute);
        }
    }

    Timer {
        id: heartBeater;
        repeat: true;
        triggeredOnStart: true;
        interval: 60000;
        onTriggered: internal.getlist();
    }

    ViewHeader {
        id: viewHeader;
        title: qsTr("Talking with %1").arg(chatName);
        onClicked: view.scrollToTop();
    }

    SilicaListView {
        id: view;
        anchors {
            left: parent.left; right: parent.right;
            top: viewHeader.bottom; bottom: toolsArea.top;
        }
        model: ListModel {}
        cacheBuffer: view.height * 5;
        delegate: chatDelegate;
        header: PullToActivate {
            myView: view;
            pullDownMessage: qsTr("View history message");
            onRefresh: internal.getlist("prev");
        }
        Component {
            id: chatDelegate;
            Item {
                id: root;
                anchors.left: isMe ? undefined : parent.left;
                anchors.right: isMe ? parent.right : undefined;
                implicitWidth: view.width - constant.graphicSizeSmall;
                implicitHeight: contentCol.height + contentCol.anchors.topMargin*2;

                BorderImage {
                    asynchronous: true;
                    source: isMe ? "../gfx/msg_out.png" : "../gfx/msg_in.png";
                    anchors { fill: parent; margins: constant.paddingLarge; }
                    border { left: 10; top: 10; right: 10; bottom: 15; }
                    mirror: true;
                }

                Column {
                    id: contentCol;
                    anchors {
                        left: parent.left; leftMargin: constant.paddingLarge+10;
                        right: parent.right; rightMargin: constant.paddingLarge+10;
                        top: parent.top; topMargin: constant.paddingLarge*2;
                    }
                    Text {
                        width: parent.width;
                        wrapMode: Text.Wrap;
                        font: constant.labelFont;
                        color: "white";
                        text: content;
                    }
                    Text {
                        width: parent.width;
                        horizontalAlignment: isMe ? Text.AlignRight : Text.AlignLeft;
                        font: constant.subTitleFont;
                        color: "white";
                        text: time;
                    }
                }
            }
        }
    }

    ScrollDecorator { flickableItem: view; }

    Floor.ToolsArea {
        id: toolsArea;
        emoticonEnabled: false;
    }

    onStatusChanged: {
        if (status === PageStatus.Deactivating){
            audioWrapper.stop();
            toolsArea.state = "";
        }
    }
}
