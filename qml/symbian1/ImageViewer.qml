import QtQuick 1.0
import com.nokia.symbian 1.0
import "Component"

MyPage {
    id: page;

    property url imageUrl;

    title: qsTr("Image viewer");

    tools: ToolBarLayout {
        BackButton {}
        ToolButtonWithTip {
            toolTipText: qsTr("Save image");
            iconSource: "gfx/save.svg";
            onClicked: {
                var path = tbsettings.imagePath + "/" + imageUrl.toString().split("/").pop();
                if (utility.saveCache(imageUrl, path)){
                    signalCenter.showMessage(qsTr("Image saved to %1").arg(path));
                } else {
                    utility.openURLDefault(imageUrl);
                }
            }
        }
    }

    Flickable {
        id: imageFlickable
        anchors.fill: parent
        contentWidth: imageContainer.width; contentHeight: imageContainer.height
        clip: true
        onHeightChanged: if (imagePreview.status === Image.Ready) imagePreview.fitToScreen()

        Item {
            id: imageContainer
            width: Math.max(imagePreview.width * imagePreview.scale, imageFlickable.width)
            height: Math.max(imagePreview.height * imagePreview.scale, imageFlickable.height)

            Image {
                id: imagePreview

                property real prevScale

                function fitToScreen() {
                    scale = Math.min(imageFlickable.width / width, imageFlickable.height / height, 1)
                    slider.minimumValue = scale;
                    prevScale = scale
                }

                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                source: imageUrl
                sourceSize.height: 1000;
                smooth: !imageFlickable.moving

                onStatusChanged: {
                    if (status == Image.Ready) {
                        fitToScreen()
                        loadedAnimation.start()
                    }
                }

                NumberAnimation {
                    id: loadedAnimation
                    target: imagePreview
                    property: "opacity"
                    duration: 250
                    from: 0; to: 1
                    easing.type: Easing.InOutQuad
                }

                onScaleChanged: {
                    slider.value = scale;
                    if ((width * scale) > imageFlickable.width) {
                        var xoff = (imageFlickable.width / 2 + imageFlickable.contentX) * scale / prevScale;
                        imageFlickable.contentX = xoff - imageFlickable.width / 2
                    }
                    if ((height * scale) > imageFlickable.height) {
                        var yoff = (imageFlickable.height / 2 + imageFlickable.contentY) * scale / prevScale;
                        imageFlickable.contentY = yoff - imageFlickable.height / 2
                    }
                    prevScale = scale
                }
            }
        }

        MouseArea {
            id: mouseArea;
            anchors.fill: parent;
            enabled: imagePreview.status === Image.Ready;
            onDoubleClicked: {
                if (imagePreview.scale > slider.minimumValue){
                    bounceBackAnimation.to = slider.minimumValue;
                    bounceBackAnimation.start()
                } else {
                    bounceBackAnimation.to = Math.min(1, slider.maximumValue);
                    bounceBackAnimation.start()
                }
            }
        }
    }

    Loader {
        anchors.centerIn: parent
        sourceComponent: {
            switch (imagePreview.status) {
            case Image.Loading:
                return loadingIndicator
            case Image.Error:
                return failedLoading
            default:
                return undefined
            }
        }

        Component {
            id: loadingIndicator

            Item {
                height: childrenRect.height
                width: page.width

                BusyIndicator {
                    id: imageLoadingIndicator
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: constant.graphicSizeLarge; width: constant.graphicSizeLarge
                    running: true
                    //platformInverted: tbsettings.whiteTheme;
                }

                Text {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: imageLoadingIndicator.bottom; topMargin: constant.paddingLarge
                    }
                    font: constant.titleFont;
                    color: constant.colorLight;
                    text: qsTr("Loading image...%1").arg(Math.round(imagePreview.progress*100) + "%")
                }
            }
        }

        Component {
            id: failedLoading
            Text {
                font: constant.titleFont;
                text: qsTr("Error loading image")
                color: constant.colorLight;
            }
        }
    }

    ScrollDecorator {
        //platformInverted: tbsettings.whiteTheme;
        flickableItem: imageFlickable
    }

    Slider {
        id: slider;

        anchors {
            left: parent.left; right: parent.right;
            bottom: parent.bottom; margins: constant.paddingLarge;
        }

        enabled: imagePreview.status === Image.Ready;
        minimumValue: 1.0;
        maximumValue: 2.0;

        onValueChanged: imagePreview.scale = value;

        NumberAnimation {
            id: bounceBackAnimation
            target: imagePreview
            duration: 250
            property: "scale"
            from: imagePreview.scale
        }
    }

    // For keypad
    onStatusChanged: {
        if (status === PageStatus.Active){
            page.forceActiveFocus();
        }
    }
}
