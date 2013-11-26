import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"
import "../Thread" as Thread

MyPage {
    id: page;

    title: tabGroup.currentTab.title;

    tools: ToolBarLayout {
        BackButton {}
        ToolButtonWithTip {
            toolTipText: qsTr("Refresh");
            iconSource: "toolbar-refresh";
            onClicked: tabGroup.currentTab.getlist();
        }
        ToolButtonWithTip {
            toolTipText: qsTr("Chat");
            iconSource: "toolbar-add";
        }
    }

    function switchTab(direction){
        var children = viewHeader.layout.children;
        if (children.length > 0){
            var index = -1;
            for (var i=0, l=children.length;i<l;i++){
                if (children[i].tab === tabGroup.currentTab){
                    index = i;
                    break;
                }
            }
            if (index >=0){
                if (direction === "left")
                    index = index > 0 ? index-1 : children.length-1;
                else
                    index = index < children.length-1 ? index+1 : 0;
                tabGroup.currentTab = children[index].tab;
            }
        }
    }

    Thread.TabHeader {
        id: viewHeader;
        Thread.ThreadButton {
            tab: pletterPage;
        }
        Thread.ThreadButton {
            tab: replyPage;
        }
        Thread.ThreadButton {
            tab: atmePage;
        }
    }

    TabGroup {
        id: tabGroup;
        anchors { fill: parent; topMargin: viewHeader.height; }
        currentTab: pletterPage;
        PletterPage {
            id: pletterPage;
            pageStack: page.pageStack;
        }
        ReplyPage {
            id: replyPage;
            pageStack: page.pageStack;
        }
        AtmePage {
            id: atmePage;
            pageStack: page.pageStack;
        }
        onCurrentTabChanged: {
            currentTab.focus();
            currentTab.takeToForeground();
        }
    }

    // For keypad
    Connections {
        target: platformPopupManager;
        onPopupStackDepthChanged: {
            if (platformPopupManager.popupStackDepth === 0
                    && page.status === PageStatus.Active){
                tabGroup.currentTab.focus();
            }
        }
    }
    onStatusChanged: {
        if (status === PageStatus.Active){
            tabGroup.currentTab.focus();
        }
    }
    Keys.onPressed: {
        switch (event.key){
        case Qt.Key_R: tabGroup.currentTab.getlist(); event.accepted = true; break;
        case Qt.Key_Left: switchTab("left"); event.accepted = true; break;
        case Qt.Key_Right: switchTab("right"); event.accepted = true; break;
        }
    }
}
