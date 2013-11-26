import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"

MyPage {
    id: page;

    title: qsTr("Search");

    tools: ToolBarLayout {
        BackButton {}
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
    }
    Item {
        id: searchItem;
        anchors.top: viewHeader.bottom;
        width: parent.width;
        height: constant.graphicSizeLarge;
        SearchInput {
            id: searchInput;
            anchors {
                left: parent.left; leftMargin: constant.paddingLarge;
                right: searchBtn.left; rightMargin: constant.paddingMedium;
                verticalCenter: parent.verticalCenter;
            }
            placeholderText: qsTr("Tap to search");
            onCleared: pageStack.pop(undefined, true);
            Keys.onPressed: {
                if (event.key == Qt.Key_Select
                        ||event.key == Qt.Key_Enter
                        ||event.key == Qt.Key_Return){
                    searchBtn.clicked();
                    event.accepted = true;
                }
            }
        }
        Button {
            id: searchBtn;
            anchors {
                right: parent.right; rightMargin: constant.paddingLarge;
                verticalCenter: parent.verticalCenter;
            }
            width: height;
            iconSource: privateStyle.toolBarIconPath("toolbar-mediacontrol-play");
            onClicked: signalCenter.enterForum(searchInput.text);
        }
    }
    ButtonRow {
        id: tabRow;
        anchors.top: searchItem.bottom;
        width: parent.width;
        TabButton {
            platformInverted: tbsettings.whiteTheme;
            text: qsTr("Search tieba");
        }
        TabButton {
            platformInverted: tbsettings.whiteTheme;
            text: qsTr("Search posts");
        }
        TabButton {
            platformInverted: tbsettings.whiteTheme;
            text: qsTr("Search web");
        }
    }
    TabGroup {
        id: tabGroup;
        anchors {
            left: parent.left; right: parent.right;
            top: tabRow.bottom; bottom: parent.bottom;
        }
        ListView {
            id: suggestView;
        }
        ListView {
            id: searchView;
        }
    }

    // For keypad
    onStatusChanged: {
        if (status === PageStatus.Active){
            searchInput.forceActiveFocus();
            searchInput.openSoftwareInputPanel();
        }
    }
}
