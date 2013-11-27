import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"
import "../../js/main.js" as Script

MyPage {
    id: page;

    title: qsTr("Create a new thread");

    PostHeader {
        id: viewHeader;
        visible: app.inPortrait;
        text: page.title;
    }

    TextField {
        id: titlefield;
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.top: viewHeader.bottom;
        anchors.margins: constant.paddingMedium;
        platformInverted: tbsettings.whiteTheme;
        KeyNavigation.down: contentArea;
        Keys.onPressed: {
            if (event.key == Qt.Key_Select
                    ||event.key == Qt.Key_Enter
                    ||event.key == Qt.Key_Return){
                contentArea.forceActiveFocus();
                contentArea.openSoftwareInputPanel();
                event.accepted = true;
            }
        }
    }

    TextArea {
        id: contentArea;
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.top: titlefield.bottom;
        anchors.bottom: toolsBanner.top;
        anchors.margins: constant.paddingMedium;
        platformInverted: tbsettings.whiteTheme;
    }

    Item {
        id: toolsBanner;
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: attachedArea.top;
        anchors.margins: constant.paddingMedium;
        height: childrenRect.height;
        Row {
            id: toolsRow;
            spacing: constant.paddingSmall;
            ToolButton {
                platformInverted: tbsettings.whiteTheme;
                iconSource: "toolbar-list";
            }
            ToolButton {
                platformInverted: tbsettings.whiteTheme;
                iconSource: "toolbar-list";
            }
            ToolButton {
                platformInverted: tbsettings.whiteTheme;
                iconSource: "toolbar-list";
            }
            ToolButton {
                platformInverted: tbsettings.whiteTheme;
                iconSource: "toolbar-list";
            }
        }
        ToolButton {
            anchors.top: app.inPortrait ? toolsRow.bottom : parent.top;
            anchors.right: parent.right;
            platformInverted: tbsettings.whiteTheme;
            text: qsTr("Post");
        }
    }

    AttchedArea {
        id: attachedArea;
        anchors.bottom: parent.bottom;
        BackButton {
            anchors { left: parent.left; bottom: parent.bottom; }
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Activating) app.showToolBar = false;
        else if (status === PageStatus.Deactivating) app.showToolBar = true;
        else if (status === PageStatus.Active){
            if (titlefield.visible){
                titlefield.forceActiveFocus();
                titlefield.openSoftwareInputPanel();
            } else {
                contentArea.forceActiveFocus();
                contentArea.openSoftwareInputPanel();
            }
        }
    }
}
