import QtQuick 1.0
import com.nokia.symbian 1.0
import "../Component"
import "../../js/main.js" as Script

Item {
    id: root;

    property int toolBarHeight: (screen.width < screen.height)
                                ? privateStyle.toolBarHeightPortrait
                                : privateStyle.toolBarHeightLandscape
    property alias text: inputArea.text;
    property alias cursorPosition: inputArea.cursorPosition;
    property alias emoticonEnabled: faceInsertBtn.enabled;

    anchors.bottom: parent.bottom;
    width: screen.width;
    height: toolBarHeight;

    Connections {
        target: signalCenter;
        onEmoticonSelected: {
            if (caller === root){
                var c = inputArea.cursorPosition;
                inputArea.text = inputArea.text.substring(0, c)+name+inputArea.text.substring(c);
                inputArea.cursorPosition = c + name.length;
            }
        }
    }

    Item {
        id: inputBar;
        y: root.height;
        opacity: 0;
        width: parent.width;
        height: Math.max(toolBarHeight, inputArea.height+constant.paddingMedium);
        BorderImage {
            anchors.fill: parent
            source: privateStyle.imagePath("qtg_fr_toolbar");
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
            visible: enabled;
            //platformInverted: tbsettings.whiteTheme;
            iconSource: "../gfx/btn_insert_face.png";
            onClicked: signalCenter.createEmoticonDialog(root);
        }
        ToolButtonWithTip {
            id: sendBtn;
            anchors {
                right: parent.right; rightMargin: app.inPortrait ? 0 : 2*constant.paddingLarge;
                verticalCenter: parent.verticalCenter;
            }
            toolTipText: qsTr("Send");
            iconSource: "../gfx/message_send.svg";
            enabled: inputArea.text.length > 0 && !inputArea.errorHighlight && !loading;
            onClicked: internal.addPost();
        }
        TextArea {
            id: inputArea;
            anchors {
                left: faceInsertBtn.enabled ? faceInsertBtn.right : inputBarCancelBtn.right;
                right: sendBtn.left;
                verticalCenter: parent.verticalCenter;
            }
            errorHighlight: Script.TextSlicer.textLength(text) > 280;
            //platformInverted: tbsettings.whiteTheme;
            platformMaxImplicitHeight: app.inPortrait ? 150 : 100;
        }
    }

    states: [
        State {
            name: "Input";
            PropertyChanges { target: app; showToolBar: false; }
            PropertyChanges { target: viewHeader; visible: app.showStatusBar; }
            PropertyChanges { target: root; height: inputBar.height; }
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
                        //inputArea.openSoftwareInputPanel();
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
