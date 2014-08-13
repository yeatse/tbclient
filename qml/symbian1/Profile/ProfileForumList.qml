import QtQuick 1.0
import com.nokia.symbian 1.0
import "../Component"
import "../Silica"
import "../../js/main.js" as Script

MyPage {
    id: page;

    property string uid;
    onUidChanged: getlist();

    property bool editMode: false;

    function getlist(){
        loading = true;
        var prop = { uid: uid, model: view.model };
        var s = function(){ loading = false; };
        var f = function(err){ loading = false; signalCenter.showMessage(err); }
        Script.getUserLikedForum(prop, s, f);
    }

    function removeForum(index){
        var model = view.model.get(index);
        var opt = { fid: model.id, favo_type: model.favo_type, kw: model.name };
        loading = true;
        var s = function(){
            loading = false;
            view.model.remove(index);
        }
        var f = function(err){
            loading = false;
            signalCenter.showMessage(err);
        }
        Script.unfavforum(opt, s, f);
    }

    tools: ToolBarLayout {
        BackButton {}
        ToolButtonWithTip {
            toolTipText: qsTr("Refresh");
            iconSource: "toolbar-refresh";
            onClicked: getlist();
        }
        ToolButtonWithTip {
            toolTipText: editMode ? qsTr("OK") : qsTr("Edit");
            iconSource: "../gfx/"+(editMode?"ok":"edit")+".svg";
            enabled: uid === tbsettings.currentUid;
            onClicked: page.editMode = !page.editMode;
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
        delegate: forumDelegate;
        header: PullToActivate {
            myView: view;
            onRefresh: getlist();
        }
        Component {
            id: forumDelegate;
            AbstractItem {
                id: root;
                onClicked: signalCenter.enterForum(name);
                Image {
                    id: logo;
                    anchors {
                        left: root.paddingItem.left;
                        top: root.paddingItem.top;
                        bottom: root.paddingItem.bottom;
                    }
                    asynchronous: true;
                    width: height;
                    source: avatar;
                }
                Column {
                    anchors {
                        left: logo.right; leftMargin: constant.paddingMedium;
                        right: rightLoader.left; rightMargin: constant.paddingMedium;
                        verticalCenter: parent.verticalCenter;
                    }
                    spacing: constant.paddingSmall;
                    Text {
                        width: parent.width;
                        elide: Text.ElideRight;
                        font: constant.titleFont;
                        color: constant.colorLight;
                        text: name;
                    }
                    Text {
                        width: parent.width;
                        elide: Text.ElideRight;
                        font: constant.subTitleFont;
                        color: constant.colorMid;
                        text: slogan;
                    }
                }
                Loader {
                    id: rightLoader;
                    anchors {
                        right: root.paddingItem.right;
                        verticalCenter: parent.verticalCenter;
                    }
                    sourceComponent: editMode ? editBtn : levelText;
                    Component {
                        id: levelText;
                        Text {
                            font: constant.titleFont;
                            color: constant.colorMid;
                            text: qsTr("Lv.%1").arg(level_id);
                        }
                    }
                    Component {
                        id: editBtn;
                        Button {
                            //platformInverted: tbsettings.whiteTheme;
                            width: height;
                            //iconSource: privateStyle.toolBarIconPath("toolbar-delete", platformInverted);
                            iconSource: privateStyle.toolBarIconPath("toolbar-delete", false);
                            onClicked: removeForum(index);
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
        case Qt.Key_R: getlist(); event.accepted = true; break;
        case Qt.Key_E: editMode = !editMode; event.accepted = true; break;
        }
    }
}
