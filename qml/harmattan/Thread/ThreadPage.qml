import QtQuick 1.1
import com.nokia.meego 1.1
import "../Component"

MyPage {
    id: page;

    title: internal.getTitle();
    tools: ToolBarLayout {
        BackButton {}
        ToolIcon {
            visible: currentTab != null;
            platformIconId: "toolbar-refresh";
            onClicked: currentTab.getlist();
        }
        ToolIcon {
            id: editBtn;
            visible: currentTab != null;
            enabled: visible && currentTab.thread != null;
            platformIconId: "toolbar-edit";
            onClicked: {
                var prop = { isReply: true, caller: currentTab }
                pageStack.push(Qt.resolvedUrl("../Post/PostPage.qml"), prop);
            }
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu";
            onClicked: internal.openMenu();
        }
    }

    property alias currentTab: tabGroup.currentTab;

    function addThreadView(option){
        internal.addThreadView(option);
    }

    QtObject {
        id: internal;

        property variant viewComp: null;
        property variant tabComp: null;
        property variant menu: null;
        property variant jumper: null;
        property variant contextMenu: null;
        property variant commonDialog: null;
        property variant manageDialog: null;

        function openMenu(){
            if (!menu)
                menu = menuComp.createObject(page);
            menu.open();
        }

        function jumpToPage(){
            if (!jumper){
                jumper = Qt.createComponent("../Dialog/PageJumper.qml").createObject(page);
                var jump = function(){
                    currentTab.currentPage = jumper.currentPage;
                    currentTab.getlist("jump");
                }
                jumper.accepted.connect(jump);
            }
            jumper.totalPage = currentTab.totalPage;
            jumper.currentPage = currentTab.currentPage;
            jumper.open();
        }

        function threadManage(){
            if (!manageDialog){
                manageDialog = Qt.createComponent("ThreadManageMenu.qml").createObject(page);
            }
            manageDialog.view = currentTab;
            manageDialog.open();
        }

        function openContextMenu(){
            if (!contextMenu)
                contextMenu = tabsManager.createObject(page);
            contextMenu.open();
        }

        function openTabCreator(){
            if (!commonDialog)
                commonDialog = tabCreator.createObject(page);
            commonDialog.open();
        }

        function getTitle(){
            if (currentTab == null){
                return qsTr("Tab page");
            } else if (currentTab.thread == null){
                return currentTab.title;
            } else {
                return currentTab.thread.title;
            }
        }

        function addThreadView(option){
            var exist = findTabButtonByThreadId(option.threadId);
            if (exist){
                currentTab = exist.tab;
                return;
            }
            restrictTabCount();
            var prop = {
                threadId: option.threadId,
                pageStack: page.pageStack
            };
            if (option.title) prop.title = option.title;
            if (option.isLz) prop.isLz = true;
            if (option.fromBookmark) prop.fromBookmark = true;

            if (!viewComp) viewComp = Qt.createComponent("ThreadView.qml");
            var view = viewComp.createObject(tabGroup, prop);
            if (!tabComp) tabComp = Qt.createComponent("ThreadButton.qml");
            tabComp.createObject(viewHeader.layout, { tab: view });

            if (option.pid)
                view.getlist(option.pid);
            else
                view.getlist();

            tabGroup.currentTab = view;
        }

        function removeThreadPage(page){
            var button = findTabButtonByTab(page);
            if (button){
                if (page == tabGroup.currentTab){
                    var i = 0, l = viewHeader.layout.children.length;
                    while (i < l-1 && button != viewHeader.layout.children[i])
                        ++i;
                    if (l > i+1)
                        tabGroup.currentTab = viewHeader.layout.children[i+1].tab;
                    else if (l > 1)
                        tabGroup.currentTab = viewHeader.layout.children[i-1].tab;
                    else
                        tabGroup.currentTab = null;
                }
                button.destroy();
                page.destroy();
            }
        }

        function removeAllThread(){
            for (var i=viewHeader.layout.children.length-1; i>=0; i--){
                var button = viewHeader.layout.children[i];
                button.tab.destroy();
                button.destroy();
            }
            currentTab = null;
        }

        function removeOtherThread(page){
            for (var i=viewHeader.layout.children.length-1; i>=0; i--){
                var button = viewHeader.layout.children[i];
                if (button.tab != page){
                    button.tab.destroy();
                    button.destroy();
                }
            }
        }

        function findTabButtonByThreadId(threadId){
            for (var i=0, l=viewHeader.layout.children.length; i<l; i++){
                var btn = viewHeader.layout.children[i];
                if (btn.tab.threadId == threadId){
                    return btn;
                }
            }
            return null;
        }
        function findTabButtonByTab(tab){
            for (var i=0, l=viewHeader.layout.children.length; i<l; i++){
                var btn = viewHeader.layout.children[i];
                if (btn.tab == tab){
                    return btn;
                }
            }
            return null;
        }

        function restrictTabCount(){
            var deleteCount = viewHeader.layout.children.length - tbsettings.maxTabCount + 1;
            for (var i=0; i<deleteCount; i++){
                viewHeader.layout.children[i].tab.destroy();
                viewHeader.layout.children[i].destroy();
            }
            currentTab = null;
        }

        function switchTab(direction){
            var children = viewHeader.layout.children;
            if (children.length > 0){
                var index = -1;
                for (var i=0, l=children.length;i<l;i++){
                    if (children[i].tab === currentTab){
                        index = i;
                        break;
                    }
                }
                if (index >=0){
                    if (direction === "left")
                        index = index > 0 ? index-1 : children.length-1;
                    else
                        index = index < children.length-1 ? index+1 : 0;
                    currentTab = children[index].tab;
                }
            }
        }
    }

    TabHeader {
        id: viewHeader;
    }

    ViewHeader {
        visible: viewHeader.layout.children.length === 0;
        title: qsTr("Tab page");
        onClicked: internal.openContextMenu();
    }

    TabGroup {
        id: tabGroup;
        anchors {
            fill: parent;
            topMargin: viewHeader.height;
        }
        onCurrentTabChanged: {
            if (currentTab) currentTab.focus();
        }
    }

    Component {
        id: menuComp;
        Menu {
            id: menu;
            property bool currentEnabled: currentTab != null && currentTab.thread != null;
            MenuLayout {
                MenuItem {
                    text: qsTr("Open browser");
                    enabled: menu.currentEnabled;
                    onClicked: signalCenter.openBrowser("http://tieba.baidu.com/p/"+currentTab.threadId);
                    ToolButton {
                        width: 0.4 * parent.width;
                        anchors {
                            right: parent.right; rightMargin: constant.paddingLarge;
                            verticalCenter: parent.verticalCenter;
                        }
                        text: qsTr("Copy url");
                        flat: false;
                        onClicked: {
                            utility.copyToClipbord("http://tieba.baidu.com/p/"+currentTab.threadId);
                            signalCenter.showMessage(qsTr("Success"));
                            menu.close();
                        }
                    }
                }
                MenuItem {
                    text: qsTr("Author only");
                    enabled: menu.currentEnabled;
                    property bool privateSelectionIndicator: menu.currentEnabled && currentTab.isLz;
                    Rectangle {
                        anchors.fill: parent;
                        color: "black";
                        opacity: parent.privateSelectionIndicator ? 0.3 : 0;
                    }
                    onClicked: {
                        currentTab.isReverse = false;
                        currentTab.isLz = !currentTab.isLz;
                        currentTab.getlist();
                    }
                }
                MenuItem {
                    text: qsTr("Reverse");
                    property bool privateSelectionIndicator: menu.currentEnabled && currentTab.isReverse;
                    Rectangle {
                        anchors.fill: parent;
                        color: "black";
                        opacity: parent.privateSelectionIndicator ? 0.3 : 0;
                    }
                    enabled: menu.currentEnabled;
                    onClicked: {
                        currentTab.isLz = false;
                        currentTab.isReverse = !currentTab.isReverse;
                        currentTab.getlist();
                    }
                }
                MenuItem {
                    text: qsTr("Jump to page");
                    enabled: menu.currentEnabled;
                    onClicked: internal.jumpToPage();
                }
                MenuItem {
                    text: qsTr("Manage");
                    enabled: menu.currentEnabled && currentTab.user.is_manager === "1";
                    onClicked: internal.threadManage();
                }
            }
        }
    }

    Component {
        id: tabsManager;
        AbstractDialog {
            id: contextMenu;
            titleText: qsTr("Tab page");
            contentList: [
                DialogItem {
                    text: qsTr("Close current tab");
                    enabled: currentTab != null;
                    onClicked: internal.removeThreadPage(currentTab);
                },
                DialogItem {
                    text: qsTr("Close other tabs");
                    enabled: currentTab != null;
                    onClicked: internal.removeOtherThread(currentTab);
                },
                DialogItem {
                    text: qsTr("Close all tabs");
                    enabled: viewHeader.layout.children.length > 0;
                    onClicked: internal.removeAllThread();
                },
                DialogItem {
                    text: qsTr("Create a new tab");
                    onClicked: internal.openTabCreator();
                }
            ]
        }
    }

    Component {
        id: tabCreator;
        Sheet {
            id: commonDialog;
            acceptButtonText: qsTr("OK");
            rejectButtonText: qsTr("Cancel");
            content: Item {
                width: parent.width;
                height: contentCol.height + constant.paddingLarge*2;
                Column {
                    id: contentCol;
                    anchors {
                        left: parent.left; right: parent.right;
                        top: parent.top; margins: constant.paddingLarge;
                    }
                    spacing: constant.paddingSmall;
                    Text {
                        width: parent.width;
                        wrapMode: Text.WrapAnywhere;
                        text: qsTr("Input url or id of the post");
                        font: constant.subTitleFont;
                        color: constant.colorMid;
                    }
                    Row {
                        width: parent.width;
                        spacing: constant.paddingMedium;
                        TextField {
                            id: textField;
                            anchors.verticalCenter: parent.verticalCenter;
                            width: parent.width - pasteButton.width - constant.paddingMedium;
                            validator: RegExpValidator {
                                regExp: /((http:\/\/)?tieba.baidu.com\/p\/)?\d+(\?.*)?/
                            }
                        }
                        Button {
                            id: pasteButton
                            anchors.verticalCenter: parent.verticalCenter;
                            platformStyle: ButtonStyle { buttonWidth: buttonHeight; }
                            iconSource: "image://theme/icon-m-toolbar-cut-paste".concat(theme.inverted?"-white":"");
                            onClicked: textField.paste();
                        }
                    }
                }
            }
            onStatusChanged: {
                if (status === DialogStatus.Open){
                    textField.text = "";
                    textField.forceActiveFocus();
                    textField.platformOpenSoftwareInputPanel();
                }
            }
            onAccepted: {
                if (textField.acceptableInput){
                    var id = textField.text.match(/\d+/)[0];
                    var option = { threadId: id };
                    internal.addThreadView(option);
                }
            }
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active){
            if (currentTab) currentTab.focus();
        } else if (status === PageStatus.Deactivating){
            audioWrapper.stop();
        }
    }
}
