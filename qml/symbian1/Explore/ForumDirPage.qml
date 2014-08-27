import QtQuick 1.0
import com.nokia.symbian 1.0
import "../Component"
import "../Silica"
import "../../js/main.js" as Script

MyPage {
    id: page;

    title: qsTr("Catalogue");

    tools: ToolBarLayout {
        BackButton {}
        ToolButtonWithTip {
            toolTipText: qsTr("Refresh");
            iconSource: "toolbar-refresh";
            onClicked: getlist();
        }
    }

    function getlist(){
        var s = function(){ loading = false; }
        var f = function(err){ loading = false; signalCenter.showMessage(err); }
        loading = true;
        Script.getForumDir(view.model, s, f);
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
        onClicked: view.scrollToTop();
    }

    SilicaListView {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        cacheBuffer: 0//view.height * 3;
        model: ListModel {}
        delegate: dirDelegate;

        Component {
            id: dirDelegate;
            AbstractItem {
                id: root;
                onClicked: {
                    var prop = { menuData: model, title: menu_name }
                    pageStack.push(Qt.resolvedUrl("ForumRankPage.qml"), prop);
                }
                Image {
                    id: logo;
                    anchors {
                        left: root.paddingItem.left; top: root.paddingItem.top;
                        bottom: root.paddingItem.bottom;
                    }
                    width: height;
                    asynchronous: true;
                    source: default_logo_url
                }
                Image {
                    id: subItemIcon;
                    asynchronous: true;
                    anchors {
                        right: parent.right;
                        rightMargin: privateStyle.scrollBarThickness;
                        verticalCenter: parent.verticalCenter;
                    }
                    source: privateStyle.imagePath("qtg_graf_drill_down_indicator");
                    sourceSize.width: platformStyle.graphicSizeSmall;
                    sourceSize.height: platformStyle.graphicSizeSmall;
                }
                Column {
                    anchors {
                        left: logo.right; leftMargin: constant.paddingMedium;
                        right: subItemIcon.left;
                        verticalCenter: parent.verticalCenter;
                    }
                    spacing: constant.paddingSmall;
                    Text {
                        text: menu_name;
                        font: constant.labelFont;
                        color: constant.colorLight;
                    }
                    Text {
                        width: parent.width;
                        elide: Text.ElideRight;
                        text: subtitle;
                        font: constant.subTitleFont;
                        color: constant.colorMid;
                    }
                }
            }
        }
    }

    ScrollDecorator {
        flickableItem: view; //platformInverted: true;
    }

    // For keypad
    onStatusChanged: {
        if (status === PageStatus.Active){
            view.forceActiveFocus();
        }
    }

    Component.onCompleted: getlist();
}
