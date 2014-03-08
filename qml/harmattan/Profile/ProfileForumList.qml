import QtQuick 1.1
import com.nokia.meego 1.1
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
        ToolIcon {
            platformIconId: "toolbar-refresh";
            onClicked: getlist();
        }
        ToolIcon {
            platformIconId: editMode ? "toolbar-done" : "toolbar-edit";
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
                            platformStyle: ButtonStyle {
                                buttonWidth: buttonHeight;
                            }
                            iconSource: "image://theme/icon-m-toolbar-delete"+(theme.inverted?"-white":"");
                            onClicked: removeForum(index);
                        }
                    }
                }
            }
        }
    }

    ScrollDecorator { flickableItem: view; }
}
