import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"
import "../Floor" as Floor
import "../../js/main.js" as Script

MyPage {
    id: page;

    property string threadId;
    property string forumName;
    onThreadIdChanged: internal.getlist();

    tools: ToolBarLayout {
        BackButton {}
        ToolButtonWithTip {
            toolTipText: qsTr("Refresh");
            iconSource: "toolbar-refresh";
            enabled: view.currentItem != null;
            onClicked: view.currentItem.getlist();
        }
        ToolButtonWithTip {
            toolTipText: qsTr("Reply");
            iconSource: "../gfx/edit"+constant.invertedString+".svg";
            enabled: view.currentItem != null;
            onClicked: toolsArea.state = "Input";
        }
        ToolButtonWithTip {
            toolTipText: qsTr("Save");
            iconSource: "../gfx/save"+constant.invertedString+".svg";
            enabled: view.currentItem != null;
            onClicked: {
                var url = view.model.get(view.currentIndex).url;
                var path = tbsettings.imagePath + "/" + url.toString().split("/").pop();
                if (utility.saveCache(url, path)){
                    signalCenter.showMessage(qsTr("Image saved to %1").arg(path));
                } else {
                    utility.openURLDefault(url);
                }
            }
        }
    }

    QtObject {
        id: internal;

        property variant forum: null;
        property int picAmount;

        function getlist(option){
            option = option||"renew";
            var opt = {
                page: internal,
                model: view.model,
                tid: threadId,
                kw: forum?forum.name:forumName
            };
            if (option == "renew"){
                opt.pic_id = "";
                opt.renew = true;
            } else {
                opt.pic_id = view.model.get(view.count-1).pic_id;
            }
            loading = true;
            function s(){ loading = false; }
            function f(err){ loading = false; signalCenter.showMessage(err); }
            Script.getPicturePage(opt, s, f);
        }

        function addPost(vcode, vcodeMd5){
            var opt = {
                tid: threadId,
                fid: forum.id,
                quote_id: view.model.get(view.currentIndex).post_id,
                content: toolsArea.text,
                kw: forum.name
            }
            if (vcode){
                opt.vcode = vcode;
                opt.vcode_md5 = vcodeMd5;
            }
            var c = view.currentItem;
            c.loading = true;
            var s = function(){
                if (c) {
                    c.loading = false;
                    c.getlist();
                }
                signalCenter.showMessage(qsTr("Success"));
                toolsArea.text = "";
                toolsArea.state = "";
            }
            var f = function(err, obj){
                if (c) c.loading = false;
                signalCenter.showMessage(err);
                if (obj && obj.info && obj.info.need_vcode === "1"){
                    signalCenter.needVCode(page, obj.info.vcode_md5, obj.info.vcode_pic_url,
                                           obj.info.vcode_type === "4");
                }
            }
            Script.floorReply(opt, s, f);
        }
    }

    Connections {
        target: signalCenter;
        onVcodeSent: if (caller === page) internal.addPost(vcode, vcodeMd5);
    }

    ListHeading {
        id: viewHeader;
        platformInverted: tbsettings.whiteTheme;
        z: 10;
        ListItemText {
            anchors.fill: parent.paddingItem;
            platformInverted: parent.platformInverted;
            role: "Heading";
            text: (view.currentIndex+1)+"/"+internal.picAmount;
        }
        BusyIndicator {
            anchors { left: parent.paddingItem.left; verticalCenter: parent.verticalCenter; }
            platformInverted: parent.platformInverted;
            running: true;
            visible: view.currentItem != null && view.currentItem.loading;
        }
    }

    ListView {
        id: view;
        focus: true;
        anchors { fill: parent; topMargin: viewHeader.height; }
        cacheBuffer: 1;
        highlightFollowsCurrentItem: true;
        highlightMoveDuration: 300;
        highlightRangeMode: ListView.StrictlyEnforceRange;
        preferredHighlightBegin: 0;
        preferredHighlightEnd: view.width;
        snapMode: ListView.SnapOneItem;
        orientation: ListView.Horizontal;
        boundsBehavior: Flickable.StopAtBounds;
        model: ListModel {}
        delegate: ThreadPictureDelegate{}
        onMovementEnded: {
            if (!atXEnd || loading) return;
            var d = view.model.get(view.count-1);
            if (!d) return;
            if (view.count >= internal.picAmount) return;
            internal.getlist("next");
        }
    }

    Floor.ToolsArea {
        id: toolsArea;
    }

    // For keypad
    onStatusChanged: {
        if (status === PageStatus.Active){
            view.forceActiveFocus();
        } else if (status === PageStatus.Deactivating){
            toolsArea.state = "";
        }
    }

    Keys.onPressed: {
        switch (event.key){
        case Qt.Key_R:
            if (view.currentItem)
                view.currentItem.getlist();
            event.accepted = true;
            break;
        case Qt.Key_E:
            if (view.currentItem)
                toolsArea.state = "Input";
            event.accepted = true;
            break;
        }
    }
}
