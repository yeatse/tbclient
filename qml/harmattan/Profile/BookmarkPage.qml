import QtQuick 1.1
import com.nokia.meego 1.1
import "../../js/main.js" as Script
import "../Component"
import "../Silica"

MyPage {
    id: page;

    tools: ToolBarLayout {
        BackButton {}
        ToolIcon {
            platformIconId: "toolbar-refresh";
            onClicked: internal.getlist();
        }
        ToolIcon {
            platformIconId: internal.editMode ? "toolbar-done" : "toolbar-edit";
            onClicked: internal.editMode = !internal.editMode;
        }
    }

    QtObject {
        id: internal;

        property bool editMode: false;
        property bool dataDirty: true;

        function getlist(option){
            option = option||"renew";
            var opt = { model: view.model }
            if (option === "renew"){
                opt.offset = 0;
                opt.renew = true;
            } else {
                opt.offset = view.count;
            }
            var s = function(){ loading = false; }
            var f = function(err){ loading = false; signalCenter.showMessage(err); }
            loading = true;
            Script.getBookmark(opt, s, f);
        }
        function removeBookmark(index){
            var opt = { add: false, tid: view.model.get(index).thread_id }
            var s = function(){ loading = false; view.model.remove(index);
                signalCenter.showMessage(qsTr("Success")) }
            var f = function(err){ loading = false; signalCenter.showMessage(err); }
            loading = true;
            Script.setBookmark(opt, s, f);
        }
    }

    Connections {
        target: signalCenter;
        onBookmarkChanged: {
            if (page.status !== PageStatus.Active)
                internal.dataDirty = true;
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
        cacheBuffer: view.height * 3;
        delegate: bmDelegate;
        header: PullToActivate {
            myView: view;
            onRefresh: internal.getlist();
        }
        footer: FooterItem {
            visible: view.count > 0;
            enabled: !loading;
            onClicked: internal.getlist("next");
        }

        Component {
            id: bmDelegate;
            AbstractItem {
                id: root;
                implicitHeight: contentCol.height + constant.paddingLarge*2;
                onClicked: {
                    var prop = {
                        threadId: thread_id, title: title, pid: mark_pid,
                        isLz: isLz, fromBookmark: true
                    }
                    signalCenter.enterThread(prop);
                }
                Column {
                    id: contentCol;
                    anchors {
                        left: root.paddingItem.left; right: root.paddingItem.right;
                        top: root.paddingItem.top;
                    }
                    spacing: constant.paddingMedium;
                    Text {
                        width: parent.width;
                        font: constant.titleFont;
                        color: constant.colorLight;
                        wrapMode: Text.Wrap;
                        text: title;
                    }
                    Text {
                        font: constant.subTitleFont;
                        color: constant.colorMid;
                        text: author;
                    }
                }
                Row {
                    anchors {
                        right: parent.right; bottom: parent.bottom;
                        margins: constant.paddingMedium;
                    }
                    Image {
                        visible: isVisible;
                        source: "../gfx/btn_icon_comment_n"+constant.invertedString;
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter;
                        text: isVisible ? reply_num : qsTr("Deleted");
                        font: constant.subTitleFont;
                        color: constant.colorMid;
                    }
                }
                Image {
                    anchors { right: root.paddingItem.right; top: root.paddingItem.top; }
                    source: "../gfx/ico_mbar_news_point.png";
                    visible: isNew;
                }
                Loader {
                    anchors {
                        right: root.paddingItem.right;
                        verticalCenter: parent.verticalCenter;
                    }
                    sourceComponent: internal.editMode ? editBtn : undefined;
                    Component {
                        id: editBtn;
                        Button {
                            platformStyle: ButtonStyle { buttonWidth: buttonHeight; }
                            iconSource: "image://theme/icon-m-toolbar-delete"+(theme.inverted?"-white":"");
                            onClicked: internal.removeBookmark(index);
                        }
                    }
                }
            }
        }
    }

    ScrollDecorator { flickableItem: view; }

    onStatusChanged: {
        if (status === PageStatus.Active){
            if (internal.dataDirty){
                internal.dataDirty = false;
                internal.getlist();
            }
        }
    }
}
