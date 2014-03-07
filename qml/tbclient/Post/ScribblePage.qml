import QtQuick 1.1
import com.nokia.symbian 1.1
import com.yeatse.tbclient 1.0
import "../Component"

MyPage {
    id: page;

    property variant caller: null;

    title: qsTr("Scribble");
    tools: defaultTools;

    ToolBarLayout {
        id: defaultTools;
        BackButton {}
        ToolButtonWithTip {
            toolTipText: qsTr("Tools");
            iconSource: "../gfx/toolbox"+constant.invertedString+".svg";
            onClicked: toolsMenu.open();
        }
        ToolButtonWithTip {
            toolTipText: qsTr("Clear");
            iconSource: "toolbar-delete";
            onClicked: scribbleArea.clear();
        }
        ToolButtonWithTip {
            id: saveButton;
            toolTipText: qsTr("Save");
            iconSource: "../gfx/ok"+constant.invertedString+".svg";
            onClicked: {
                var filename = "scribble_"+Qt.formatDateTime(new Date(), "yyyyMMddhhmmss")+".jpg";
                var path = tbsettings.imagePath + "/" + filename;
                if (scribbleArea.save(path)){
                    signalCenter.imageSelected(caller, path);
                    pageStack.pop();
                } else {
                    signalCenter.showMessage(qsTr("Cannot save image"));
                }
            }
        }
    }

    ToolBarLayout {
        id: importTools;
        ToolButton {
            platformInverted: tbsettings.whiteTheme;
            text: qsTr("OK");
            onClicked: {
                scribbleArea.loadImage(importer.source, imageLoader.x, imageLoader.y);
                importer.state = "";
                importer.source = "";
            }
        }
        ToolButton {
            platformInverted: tbsettings.whiteTheme;
            text: qsTr("Cancel");
            onClicked: {
                importer.state = "";
                importer.source = "";
            }
        }
    }

    ScribbleArea {
        id: scribbleArea;
        anchors.fill: parent;
    }

    Item {
        id: importer;
        property string source;
        onSourceChanged: imageLoader.modified = false;

        anchors.fill: parent;
        visible: false;

        MouseArea {
            id: filter;
            anchors.fill: parent;
        }

        Item {
            id: imageLoader;
            property bool modified: false;
            Image {
                anchors.fill: parent;
                source: importer.source == "" ? "" : "file:///"+importer.source;
                cache: false;
                asynchronous: true;
                onStatusChanged: {
                    if (status == Image.Ready && !imageLoader.modified){
                        imageLoader.modified = true;
                        fitToScreen();
                    }
                }
                onSourceChanged: {
                    if (source == "")
                        sourceSize = undefined;
                }
                function fitToScreen(){
                    var scale = 1;
                    if (sourceSize.width > importer.width||sourceSize.height > importer.height){
                        if (sourceSize.width / sourceSize.height > importer.width / importer.height){
                            scale = importer.width / sourceSize.width;
                        } else {
                            scale = importer.height / sourceSize.height;
                        }
                    }
                    imageLoader.width = sourceSize.width * scale;
                    imageLoader.height = sourceSize.height * scale;
                    imageLoader.x = 0;
                    imageLoader.y = 0;
                    sourceSize = Qt.size(width, height);
                }
            }
            MouseArea {
                anchors.fill: parent;
                drag {
                    target: imageLoader;
                    minimumX: -importer.width;
                    maximumX: importer.width;
                    minimumY: -importer.height;
                    maximumY: importer.height;
                }
            }
        }
        states: [
            State {
                name: "show";
                PropertyChanges { target: importer; visible: true; }
            }
        ]
        transitions: [
            Transition {
                to: "";
                ScriptAction {
                    script: pageStack.toolBar.setTools(defaultTools, "replace");
                }
            },
            Transition {
                to: "show";
                ScriptAction {
                    script: pageStack.toolBar.setTools(importTools, "replace");
                }
            }
        ]
    }

    Menu {
        id: toolsMenu;
        MenuLayout {
            MenuItem {
                text: qsTr("Pen color");
                Rectangle {
                    anchors {
                        right: parent.right; top: parent.top; bottom: parent.bottom;
                        margins: constant.paddingLarge;
                    }
                    width: height;
                    color: scribbleArea.color;
                }
                onClicked: {
                    scribbleArea.color = utility.selectColor(scribbleArea.color);
                }
            }
            MenuItem {
                text: qsTr("Pen width");
                Text {
                    anchors {
                        right: parent.right; rightMargin: constant.paddingLarge;
                        verticalCenter: parent.verticalCenter;
                    }
                    font: constant.labelFont;
                    color: platformStyle.colorNormalLight;
                    text: scribbleArea.penWidth+"";
                }
                onClicked: widthSelector.open();
            }
            MenuItem {
                text: qsTr("Import picture");
                onClicked: {
                    var url = utility.selectImage();
                    if (url !== ""){
                        importer.source = url;
                        importer.state = "show";
                    }
                }
            }
        }
    }

    CommonDialog {
        id: widthSelector
        titleText: qsTr("Select pen width(selected: %1)").arg(slider.value);
        buttonTexts: [ qsTr("OK"), qsTr("Cancel")];
        onButtonClicked: if (index === 0) accept();
        onAccepted: scribbleArea.penWidth = slider.value;
        content: Slider {
            id: slider
            anchors {
                left: parent.left;
                right: parent.right;
                margins: constant.paddingLarge
                verticalCenter: parent.verticalCenter
            }
            minimumValue: 1
            maximumValue: 40
            stepSize: 1
            value: scribbleArea.penWidth
            Keys.onPressed: {
                if (event.key == Qt.Key_Select
                        ||event.key == Qt.Key_Enter
                        ||event.key == Qt.Key_Return){
                    widthSelector.accept();
                    event.accepted = true;
                } else if (event.key == Qt.Key_Backspace){
                    widthSelector.reject();
                    event.accepted = true;
                }
            }
        }
        onStatusChanged: {
            if (status === DialogStatus.Open){
                slider.forceActiveFocus();
            }
        }
    }

    // For keypad
    Connections {
        target: platformPopupManager;
        onPopupStackDepthChanged: {
            if (platformPopupManager.popupStackDepth === 0
                    && page.status === PageStatus.Active){
                page.forceActiveFocus();
            }
        }
    }
    onStatusChanged: {
        if (status === PageStatus.Active){
            page.forceActiveFocus();
        }
    }

    Keys.onPressed: {
        if (importer.state == "" && platformPopupManager.popupStackDepth === 0){
            switch (event.key){
            case Qt.Key_M:
                toolsMenu.open();
                event.accepted = true;
                break;
            case Qt.Key_Enter:
            case Qt.Key_Return:
            case Qt.Key_Select:
                saveButton.clicked();
                event.accepted = true;
                break;
            }
        }
    }
}
