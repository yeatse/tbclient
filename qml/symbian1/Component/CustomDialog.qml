import QtQuick 1.0
import com.nokia.symbian 1.0

CommonDialog {
    id: root;

    property variant buttonTexts: []
    signal buttonClicked(int index);
    /*property url titleIcon*/

    onButtonTextsChanged: {
        for (var i = buttonRow.children.length; i > 0; --i) {
            buttonRow.children[i - 1].destroy()
        }
        for (var j = 0; j < buttonTexts.length; ++j) {
            var button = buttonComponent.createObject(buttonRow)
            button.text = buttonTexts[j]
            button.index = j
        }
    }

    Component {
        id: buttonComponent
        ToolButton {
            property int index

            width: internal.buttonWidth()
            height: privateStyle.toolBarHeightLandscape

            onClicked: {
                if (root.status == DialogStatus.Open) {
                    root.buttonClicked(index)
                    root.close()
                }
            }
        }
    }

    QtObject {
        id: internal;
        function buttonWidth() {
            switch (buttonTexts.length) {
                case 0: return 0
                case 1: return Math.round((privateStyle.dialogMaxSize - 3 * platformStyle.paddingMedium) / 2)
                default: return (buttonContainer.width - (buttonTexts.length + 1) *
                    platformStyle.paddingMedium) / buttonTexts.length
            }
        }/*
        function iconSource() {
            if (privateCloseIcon) {
                return privateStyle.imagePath((iconMouseArea.pressed && !iconMouseArea.pressCancelled
                    ? "qtg_graf_popup_close_pressed"
                    : "qtg_graf_popup_close_normal"),
                    root.platformInverted)
            } else {
                return root.titleIcon
            }
        }*/
    }
    /*
    title: Item {
        anchors.left: parent.left
        anchors.right: parent.right
        height: platformStyle.graphicSizeSmall + 2 * platformStyle.paddingLarge

        //LayoutMirroring.enabled: privateCloseIcon ? false : undefined
        //LayoutMirroring.childrenInherit: true

        Item {
            id: titleLayoutHelper // needed to make the text mirror correctly

            anchors.left: parent.left
            anchors.right: titleAreaIcon.source == "" ? parent.right : titleAreaIcon.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: platformStyle.paddingLarge

            Text {
                id: titleAreaText

                //LayoutMirroring.enabled: root.LayoutMirroring.enabled

                anchors.fill: parent
                font { family: platformStyle.fontFamilyRegular; pixelSize: platformStyle.fontSizeLarge }
                color: root.platformInverted ? platformStyle.colorNormalLinkInverted
                                             : platformStyle.colorNormalLink
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }
        }

        Image {
            id: titleAreaIcon

            anchors.right: parent.right
            anchors.rightMargin: platformStyle.paddingLarge
            anchors.verticalCenter: parent.verticalCenter
            source: internal.iconSource()
            sourceSize.height: platformStyle.graphicSizeSmall
            sourceSize.width: platformStyle.graphicSizeSmall

            MouseArea {
                id: iconMouseArea

                property bool pressCancelled

                anchors.centerIn: parent
                width: parent.width + 2 * platformStyle.paddingLarge
                height: parent.height + 2 * platformStyle.paddingLarge
                enabled: privateCloseIcon && root.status == DialogStatus.Open

                onPressed: {
                    pressCancelled = false
                    privateStyle.play(Symbian.BasicButton)
                }
                onClicked: {
                    if (!pressCancelled)
                        root.reject()
                }
                onReleased: {
                    if (!pressCancelled)
                        privateStyle.play(Symbian.PopupClose)
                }
                onExited: pressCancelled = true
            }
        }
    }*/

    buttons: Item {
        id: buttonContainer

        width: parent.width
        height: buttonTexts.length ? privateStyle.toolBarHeightLandscape + 2 * platformStyle.paddingSmall : 0

        Row {
            id: buttonRow
            objectName: "buttonRow"
            anchors.centerIn: parent
            spacing: platformStyle.paddingMedium
        }
    }
}
