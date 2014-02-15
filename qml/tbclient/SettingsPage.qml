import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "Silica"

MyPage {
    id: page;

    title: qsTr("Settings");
    tools: ToolBarLayout {
        BackButton {}
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
        onClicked: view.scrollToTop();
    }

    SilicaFlickable {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        contentWidth: view.width;
        contentHeight: contentCol.height + constant.paddingLarge*2;

        Column {
            id: contentCol;
            anchors { top: parent.top; topMargin: constant.paddingLarge; }
            width: parent.width;
            Column {
                x: constant.paddingLarge;
                spacing: constant.paddingLarge;
                CheckBox {
                    text: qsTr("Night theme");
                    platformInverted: tbsettings.whiteTheme;
                    checked: !tbsettings.whiteTheme;
                    onClicked: tbsettings.whiteTheme = !checked;
                }
                CheckBox {
                    text: qsTr("Show image");
                    platformInverted: tbsettings.whiteTheme;
                    checked: tbsettings.showImage;
                    onClicked: tbsettings.showImage = checked;
                }
                CheckBox {
                    text: qsTr("Show abstract");
                    platformInverted: tbsettings.whiteTheme;
                    checked: tbsettings.showAbstract;
                    onClicked: tbsettings.showAbstract = checked;
                }
                CheckBox {
                    text: qsTr("Monitor network changes");
                    platformInverted: tbsettings.whiteTheme;
                    checked: tbsettings.monitorNetworkMode;
                    onClicked: tbsettings.monitorNetworkMode = checked;
                }
            }
            Text {
                x: constant.paddingLarge;
                height: constant.graphicSizeSmall;
                font: constant.labelFont;
                color: constant.colorLight;
                text: qsTr("Font size");
                verticalAlignment: Text.AlignBottom;
            }
            Slider {
                minimumValue: constant.fontXSmall;
                maximumValue: constant.fontXXLarge;
                value: tbsettings.fontSize;
                platformInverted: tbsettings.whiteTheme;
                anchors { left: parent.left; right: parent.right; margins: constant.paddingLarge; }
                stepSize: 1;
                valueIndicatorVisible: true;
                onPressedChanged: {
                    if (!pressed){
                        tbsettings.fontSize = value;
                    }
                }
            }
            Text {
                x: constant.paddingLarge;
                height: constant.graphicSizeSmall;
                font: constant.labelFont;
                color: constant.colorLight;
                text: qsTr("Max tabs count");
                verticalAlignment: Text.AlignBottom;
            }
            Slider {
                minimumValue: 1;
                maximumValue: 10;
                value: tbsettings.maxTabCount;
                platformInverted: tbsettings.whiteTheme;
                anchors { left: parent.left; right: parent.right; margins: constant.paddingLarge; }
                stepSize: 1;
                valueIndicatorVisible: true;
                onPressedChanged: {
                    if (!pressed){
                        tbsettings.maxTabCount = value;
                    }
                }
            }
            SelectionListItem {
                property variant remindDialog: null;
                platformInverted: tbsettings.whiteTheme;
                title: qsTr("Remind settings");
                subTitle: qsTr("Click to set");
                onClicked: {
                    if (!remindDialog)
                        remindDialog = Qt.createComponent("Dialog/RemindSettingDialog.qml").createObject(parent);
                    remindDialog.open();
                }
            }
            SelectionListItem {
                platformInverted: tbsettings.whiteTheme;
                title: qsTr("Background image(long press to clear)");
                subTitle: tbsettings.bgImageUrl || qsTr("Click to set")
                onPressAndHold: tbsettings.bgImageUrl = "";
                onClicked: tbsettings.bgImageUrl = utility.selectImage()||tbsettings.bgImageUrl;
            }
            SelectionListItem {
                platformInverted: tbsettings.whiteTheme;
                title: qsTr("Image save path");
                subTitle: tbsettings.imagePath;
                onClicked: tbsettings.imagePath = utility.selectFolder()||tbsettings.imagePath;
            }
            SelectionListItem {
                platformInverted: tbsettings.whiteTheme;
                title: clientTypeSelector.titleText;
                subTitle: clientTypeSelector.model[clientTypeSelector.selectedIndex];
                onClicked: clientTypeSelector.open();
                SelectionDialog {
                    id: clientTypeSelector;
                    titleText: qsTr("User agent");
                    model: ["iPhone","Android"]//,"Windows Phone","Windows 8",qsTr("Others")];
                    selectedIndex: tbsettings.clientType-1;
                    onAccepted: tbsettings.clientType = selectedIndex + 1;
                }
            }
            SelectionListItem {
                property variant signatureDiag: null;
                platformInverted: tbsettings.whiteTheme;
                title: qsTr("Signature")
                subTitle: tbsettings.signature.replace(/(^\s*)|(\s*$)/g,"").replace(/\s/g," ")||qsTr("Click to set");
                onClicked: {
                    if (!signatureDiag)
                        signatureDiag = Qt.createComponent("Dialog/SignatureDialog.qml").createObject(parent);
                    signatureDiag.open();
                }
            }
            SelectionListItem {
                platformInverted: tbsettings.whiteTheme;
                title: browserSelector.titleText;
                subTitle: browserSelector.model[browserSelector.selectedIndex];
                onClicked: browserSelector.open();
                SelectionDialog {
                    id: browserSelector;
                    titleText: qsTr("Default browser")
                    model: [
                        qsTr("Built-in"),
                        qsTr("System browser"),
                        qsTr("UC"),
                        qsTr("UC International"),
                        qsTr("Opera Mobile")
                    ]
                    selectedIndex: {
                        switch (tbsettings.browser){
                        case "System": return 1;
                        case "UC": return 2;
                        case "UC International": return 3;
                        case "Opera": return 4;
                        default: return 0;
                        }
                    }
                    onAccepted: {
                        switch (selectedIndex){
                        case 1: tbsettings.browser = "System"; break;
                        case 2: tbsettings.browser = "UC"; break;
                        case 3: tbsettings.browser = "UC International"; break;
                        case 4: tbsettings.browser = "Opera"; break;
                        default: tbsettings.browser = ""; break;
                        }
                    }
                }
            }
            Item { width: 1; height: constant.paddingLarge; }
            Button {
                platformInverted: tbsettings.whiteTheme;
                anchors { left: parent.left; right: parent.right; margins: constant.paddingLarge*2; }
                text: qsTr("Clear cache");
                onClicked: {
                    utility.clearCache();
                    signalCenter.clearLocalCache();
                    signalCenter.showMessage(qsTr("Operation completed"));
                }
            }
            Item { width: 1; height: constant.paddingLarge; }
            Button {
                platformInverted: tbsettings.whiteTheme;
                anchors { left: parent.left; right: parent.right; margins: constant.paddingLarge*2; }
                text: qsTr("Clear cookies");
                onClicked: {
                    utility.clearCookies();
                    signalCenter.showMessage(qsTr("Operation completed"));
                }
            }
        }
    }

    ScrollDecorator { flickableItem: view; platformInverted: tbsettings.whiteTheme; }

    // For keypad
    Connections {
        target: platformPopupManager;
        onPopupStackDepthChanged: {
            if (platformPopupManager.popupStackDepth === 0
                    && page.status === PageStatus.Active){
                view.forceActiveFocus();
            }
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active){
            view.forceActiveFocus();
        }
    }
}
