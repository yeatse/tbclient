import QtQuick 1.0
import com.nokia.symbian 1.0

Item {
    id: root;

    property variant imageList: [];

    width: parent.width; height: parent.height;

    QtObject {
        id: internal;
        property variant menuComp: null;
        function selectImage(){
            if (!menuComp) menuComp = Qt.createComponent("SelectionMethodMenu.qml");
            menuComp.createObject(root).caller = root;
        }
        function imageSelected(urls){
            if (urls.length > 0){
                var newList = [];
                var urlList = urls.split("\n");
                imageList.forEach(function(value){newList.push(value)});
                urlList = urlList.filter(function(value){return newList.indexOf(value) === -1});
                imageList = newList.concat(urlList).slice(0,10);
            }
        }
        function removeImage(url){
            imageList = imageList.filter(function(value){return value != url});
        }
    }

    Connections {
        target: signalCenter;
        onImageSelected: {
            if (caller === root){
                internal.imageSelected(urls);
            }
        }
    }

    BorderImage {
        anchors.fill: parent;
        source: privateStyle.imagePath("qtg_fr_list_heading_normal");
        border { left: 28; top: 5; right: 28; bottom: 0 }
    }
    Flickable {
        anchors.fill: parent;
        contentWidth: Math.max(parent.width, imageInsertRow.width);
        contentHeight: parent.height;
        Row {
            id: imageInsertRow;
            anchors.centerIn: parent;
            spacing: constant.paddingLarge;
            Repeater {
                model: root.imageList;
                Item {
                    width: constant.thumbnailSize;
                    height: constant.thumbnailSize;
                    Image {
                        anchors.fill: parent;
                        fillMode: Image.PreserveAspectCrop;
                        sourceSize.width: parent.width;
                        source: "file:///"+modelData;
                        clip: true;
                        asynchronous: true;
                    }
                    ToolButton {
                        anchors {
                            top: parent.top; right: parent.right;
                            margins: -constant.paddingMedium;
                        }
                        //platformInverted: tbsettings.whiteTheme;
                        iconSource: "../gfx/tb_close_stop.svg";
                        onClicked: internal.removeImage(modelData);
                    }
                }
            }
            Item {
                width: constant.thumbnailSize;
                height: constant.thumbnailSize;
                visible: imageList.length < 10;
                Button {
                    width: height;
                    anchors.centerIn: parent;
                    //platformInverted: tbsettings.whiteTheme;
                    //iconSource: privateStyle.toolBarIconPath("toolbar-add", platformInverted);
                    iconSource: privateStyle.toolBarIconPath("toolbar-add", false);
                    onClicked: internal.selectImage();
                }
            }
        }
    }
}
