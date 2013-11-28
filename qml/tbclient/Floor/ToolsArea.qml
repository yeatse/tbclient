import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"
import "../../js/Utils.js" as Utils

Item {
    id: root;

    anchors.bottom: parent.bottom;
    width: screen.width;
    height: toolBar.height;

    ToolBar {
        id: toolBar;
        y: root.height - height;
        opacity: 1;
        tools: ToolBarLayout {
            BackButton {}
            ToolButtonWithTip {
                toolTipText: qsTr("Refresh");
                iconSource: "toolbar-refresh";
            }
            ToolButtonWithTip {
                toolTipText: qsTr("Reply");
                iconSource: "../../gfx/edit"+constant.invertedString+".svg";
                onClicked: root.state = "Input";
            }
            ToolButtonWithTip {
                toolTipText: qsTr("Menu");
                iconSource: "toolbar-menu";
            }
        }
    }

    Item {
        id: inputBar;
        y: root.height;
        opacity: 0;
        width: parent.width;
        height: Math.max(toolBar.height, inputArea.height+constant.paddingMedium);
        BorderImage {
            anchors.fill: parent
            source: privateStyle.imagePath("qtg_fr_toolbar", tbsettings.whiteTheme);
            border { left: 20; top: 20; right: 20; bottom: 20 }
        }
        ToolButtonWithTip {
            id: inputBarCancelBtn;
            anchors {
                left: parent.left; leftMargin: app.inPortrait ? 0 : 2*constant.paddingLarge;
                verticalCenter: parent.verticalCenter;
            }
            toolTipText: qsTr("Cancel");
            iconSource: "toolbar-back";
            onClicked: root.state = "";
        }
        ToolButton {
            id: faceInsertBtn;
            anchors {
                left: inputBarCancelBtn.right;
                verticalCenter: parent.verticalCenter;
            }
            platformInverted: tbsettings.whiteTheme;
            iconSource: "../../gfx/btn_insert_face"+constant.invertedString+".png";
        }
        ToolButtonWithTip {
            id: sendBtn;
            anchors {
                right: parent.right; rightMargin: app.inPortrait ? 0 : 2*constant.paddingLarge;
                verticalCenter: parent.verticalCenter;
            }
            toolTipText: qsTr("Send");
            iconSource: "../../gfx/message_send"+constant.invertedString+".svg";
        }
        TextArea {
            id: inputArea;
            anchors {
                left: faceInsertBtn.right; right: sendBtn.left;
                verticalCenter: parent.verticalCenter;
            }
            platformInverted: tbsettings.whiteTheme;
            platformMaxImplicitHeight: 150;
            onTextChanged: {
                var max = 280;
                if (Utils.TextSlicer.textLength(text) > max){
                    text = Utils.TextSlicer.slice(text, max);
                }
            }
        }
    }

    states: [
        State {
            name: "Input";
            PropertyChanges { target: viewHeader; visible: app.showStatusBar; }
            PropertyChanges { target: root; height: inputBar.height; }
            PropertyChanges { target: toolBar; y: root.height; opacity: 0; }
            PropertyChanges { target: inputBar; y: 0; opacity: 1; }
        }
    ]

    transitions: [
        Transition {
            to: "Input";
            SequentialAnimation {
                PropertyAnimation { properties: "y,opacity"; }
                ScriptAction {
                    script: {
                        inputArea.forceActiveFocus();
                        inputArea.openSoftwareInputPanel();
                    }
                }
            }
        },
        Transition {
            to: "";
            PropertyAnimation { properties: "y,opacity"; }
            ScriptAction {
                script: view.forceActiveFocus();
            }
        }
    ]

    // For keypad
    Connections {
        target: platformPopupManager;
        onPopupStackDepthChanged: {
            if (platformPopupManager.popupStackDepth === 0
                    && page.status === PageStatus.Active){
                if (root.state == "") view.forceActiveFocus();
                else inputArea.forceActiveFocus();
            }
        }
    }
}
