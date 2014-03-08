import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.gallery 1.1

Sheet {
    id: root;

    property variant caller;

    property int __isPage;  //to make sheet happy
    property bool __isClosing: false;
    onStatusChanged: {
        if (status == DialogStatus.Closing){
            __isClosing = true;
        } else if (status == DialogStatus.Closed && __isClosing){
            root.destroy(250);
        }
    }
    Component.onCompleted: open();

    acceptButtonText: "取消";

    title: Text {
        font.pixelSize: constant.fontXXLarge;
        color: constant.colorLight;
        anchors { left: parent.left; leftMargin: constant.paddingXLarge; verticalCenter: parent.verticalCenter; }
        text: "选择图片";
    }

    DocumentGalleryModel {
        id: galleryModel;
        autoUpdate: true;
        rootType: DocumentGallery.Image;
        properties: ["url", "title", "lastModified", "dateTaken"];
        sortProperties: ["-lastModified","-dateTaken", "+title"];
    }

    content: GridView {
        id: galleryView;
        model: galleryModel;
        anchors.fill: parent;
        clip: true;
        cellWidth: Math.floor(app.inPortrait ? width/3 : width/5);
        cellHeight: cellWidth;

        delegate: MouseArea {
            implicitWidth: GridView.view.cellWidth;
            implicitHeight: GridView.view.cellHeight;

            onClicked: {
                signalCenter.imageSelected(caller, url.replace("file://", ""));
                root.accept();
            }

            Image {
                anchors.fill: parent;
                sourceSize.width: parent.width;
                asynchronous: true;
                source: model.url;
                fillMode: Image.PreserveAspectCrop;
                clip: true;
                opacity: parent.pressed ? 0.7 : 1;
            }
        }
    }
}
