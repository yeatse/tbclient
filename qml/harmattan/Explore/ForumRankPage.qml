import QtQuick 1.1
import com.nokia.meego 1.1
import "../Component"
import "../Silica"
import "../../js/main.js" as Script

MyPage {
    id: page;

    property variant menuData;
    onMenuDataChanged: {
        internal.menuName = menuData.menu_name;
        internal.menuType = menuData.menu_type === "0" ? "136" : "9";
        internal.getdir();
        internal.getlist();
    }

    loadingVisible: loading && leftView.count === 0;

    tools: ToolBarLayout {
        BackButton {}
        ToolIcon {
            platformIconId: "toolbar-refresh";
            onClicked: internal.getlist();
        }
    }

    QtObject {
        id: internal;

        property string menuType;
        property string menuName;

        property bool tabVisible: menuData ? menuData.menu_type === "1" : false;
        property bool dirLoading: false;
        property alias leftName: leftButton.text;
        property alias rightName: rightButton.text;
        property bool hasMore: false;
        property int offset: 0;

        function getlist(option){
            option = option||"renew";
            var opt = {
                page: internal,
                leftModel: leftView.model,
                rightModel: rightView.model,
                menu_type: menuType,
                menu_name: menuName
            }
            if (option === "renew"){
                opt.renew = true;
                opt.offset = 0;
            } else {
                opt.offset = offset;
            }
            var s = function(){ loading = false; }
            var f = function(err){ loading = false; signalCenter.showMessage(err); }
            loading = true;
            Script.getForumRank(opt, s, f);
        }

        function getdir(){
            var opt = {
                menu_type: menuData.menu_type,
                menu_name: menuData.menu_name,
                menu_id: menuData.menu_id,
                model: secondDirDialog.model
            }
            var s = function(){ dirLoading = false; secondDirDialog.selectedIndex = 0; }
            var f = function(err){ dirLoading = false; signalCenter.showMessage(err); }
            dirLoading = true;
            Script.getForumDir2(opt, s, f);
        }
    }

    SelectionDialog {
        id: secondDirDialog;
        titleText: page.title;
        model: ListModel {}
        onAccepted: {
            var m = model.get(selectedIndex);
            if (selectedIndex == 0){
                internal.menuType = m.menu_type === "0" ? "136" : "9";
            } else {
                internal.menuType = m.menu_type === "0" ? "137" : "10";
            }
            internal.menuName = m.menu_name;
            viewHeader.title = m.menu_name;
            internal.getlist();
        }
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
        onClicked: tabGroup.currentTab.scrollToTop();
        ToolIcon {
            anchors {
                right: parent.right; rightMargin: constant.paddingMedium;
                verticalCenter: parent.verticalCenter;
            }
            enabled: !internal.dirLoading;
            iconSource: "image://theme/icon-m-common-filter";
            onClicked: secondDirDialog.open();
        }
    }

    ButtonRow {
        id: tabButtonContainer;
        visible: internal.tabVisible;
        anchors { left: parent.left; right: parent.right; top: viewHeader.bottom; }
        style: TabButtonStyle {}
        TabButton {
            id: leftButton;
            tab: leftView;
        }
        TabButton {
            id: rightButton;
            tab: rightView;
        }
    }

    TabGroup {
        id: tabGroup;
        anchors {
            left: parent.left; right: parent.right; bottom: parent.bottom;
            top: internal.tabVisible ? tabButtonContainer.bottom : viewHeader.bottom;
        }
        clip: true;
        currentTab: leftView;
        onCurrentTabChanged: {
            tabGroup.currentTab.forceActiveFocus();
        }
        SilicaListView {
            id: leftView;
            anchors.fill: parent;
            model: ListModel {}
            delegate: ForumRankDelegate {}
            footer: FooterItem {
                visible: leftView.count > 0;
                enabled: !loading;
                onClicked: internal.getlist("next");
            }
        }
        SilicaListView {
            id: rightView;
            anchors.fill: parent;
            model: ListModel {}
            delegate: ForumRankDelegate {}
            footer: FooterItem {
                visible: rightView.count > 0;
                enabled: !loading;
                onClicked: internal.getlist("next");
            }
        }
    }
}
