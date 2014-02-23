import QtQuick 1.1
import com.nokia.meego 1.1
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
        ToolIcon {
            platformIconId: "toolbar-tools";
            onClicked: toolsMenu.open();
        }
        ToolIcon {
            platformIconId: "toolbar-delete";
            onClicked: scribbleArea.clear();
        }
        ToolIcon {
            id: saveButton;
            platformIconId: "toolbar-done";
            onClicked: {
                var filename = "scribble_"+Qt.formatDateTime(new Date(), "yyyyMMddhhmmss")+".jpg";
                var path = tbsettings.imagePath + "/" + filename;
                console.log(path);
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
        visible: false;
        ToolIcon {
            platformIconId: "toolbar-done";
            onClicked: {
                scribbleArea.loadImage(importer.source, imageLoader.x, imageLoader.y);
                importer.state = "";
                importer.source = "";
            }
        }
        ToolIcon {
            platformIconId: "toolbar-delete";
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
                PropertyChanges { target: defaultTools; visible: false; }
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

    Connections {
        target: signalCenter;
        onImageSelected: {
            if (caller == page){
                importer.source = urls;
                importer.state = "show";
            }
        }
    }

    Sheet {
        id: toolsMenu;
        acceptButtonText: qsTr("OK");
        title: Text {
            font.pixelSize: constant.fontXXLarge;
            color: constant.colorLight;
            anchors { left: parent.left; leftMargin: constant.paddingXLarge; verticalCenter: parent.verticalCenter; }
            text: qsTr("Tools");
        }
        content: Flickable {
            anchors.fill: parent;
            contentWidth: width;
            contentHeight: contentCol.height+constant.paddingLarge*2;
            clip: true;
            Column {
                id: contentCol;
                anchors {
                    left: parent.left; right: parent.right;
                    top: parent.top; margins: constant.paddingLarge;
                }
                Button {
                    width: parent.width;
                    text: qsTr("Import picture");
                    onClicked: {
                        toolsMenu.accept();
                        signalCenter.selectImage(page);
                    }
                }
                Text {
                    height: constant.graphicSizeSmall;
                    text: qsTr("Select pen width(selected: %1)").arg(slider.value);
                    verticalAlignment: Text.AlignVCenter;
                    font: constant.labelFont;
                    color: constant.colorLight;
                }
                Slider {
                    id: slider
                    width: parent.width;
                    minimumValue: 1
                    maximumValue: 40
                    stepSize: 1
                    value: scribbleArea.penWidth
                    onPressedChanged: {
                        if (!pressed){
                            scribbleArea.penWidth = slider.value;
                        }
                    }
                }
                Text {
                    height: constant.graphicSizeSmall;
                    text: qsTr("Pen color");
                    verticalAlignment: Text.AlignVCenter;
                    font: constant.labelFont;
                    color: constant.colorLight;
                }

                Rectangle {
                    id: indicator;
                    width: parent.width;
                    height: constant.graphicSizeSmall;
                    color: scribbleArea.color;
                }

                Repeater {
                    model: 4;
                    Slider {
                        objectName: "colorS";
                        width: parent.width;
                        minimumValue: 0;
                        maximumValue: 255;
                        stepSize: 1;
                        valueIndicatorVisible: true;
                        onPressedChanged: {
                            if (!pressed){
                                scribbleArea.color = toolsMenu.getColorValue();
                            }
                        }
                        value: index == 3 ? 255 : 0;
                    }
                }
            }
        }
        function getColorValue(){
            var v = [];
            for (var i=0; i<contentCol.children.length; i++){
                var c = contentCol.children[i];
                if (c.objectName == "colorS"){
                    v.push(c.value/255);
                }
            }
            return Qt.rgba(v[0], v[1], v[2], v[3]);
        }
    }
}
