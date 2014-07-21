import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"

MyPage {
    id: page;

    property url imageUrl;
    property variant caller;

    tools: ToolBarLayout {
        BackButton {}
        ToolButtonWithTip {
            toolTipText: qsTr("OK");
            iconSource: "../gfx/ok"+constant.invertedString+".svg";
            onClicked: {
                var cutImage = utility.cutImage(imageUrl,
                                                imagePreview.scale,
                                                imageFlickable.contentX,
                                                imageFlickable.contentY,
                                                imageFlickable.width,
                                                imageFlickable.height);
                if (cutImage !== ""){
                    caller.avatarUrl = "";
                    caller.avatarUrl = cutImage;
                    pageStack.pop();
                } else {
                    signalCenter.showMessage(qsTr("Cannot save avatar"));
                }
            }
        }
    }
    ListHeading {
        id: viewHeader;
        platformInverted: tbsettings.whiteTheme;
        z: 10;
        ListItemText {
            anchors.fill: parent.paddingItem;
            role: "Heading";
            platformInverted: parent.platformInverted;
            text: qsTr("Edit avatar");
        }
    }
    Item {
        id: container;
        anchors { fill: parent; topMargin: viewHeader.height; }

        Flickable {
            id: imageFlickable
            width: Math.min(parent.height, parent.width);
            height: width;
            anchors.centerIn: parent;

            contentWidth: imageContainer.width; contentHeight: imageContainer.height
            onHeightChanged: if (imagePreview.status === Image.Ready) imagePreview.fitToScreen()

            Item {
                id: imageContainer
                width: Math.max(imagePreview.width * imagePreview.scale, imageFlickable.width)
                height: Math.max(imagePreview.height * imagePreview.scale, imageFlickable.height)

                Image {
                    id: imagePreview

                    property real prevScale

                    function fitToScreen() {
                        scale = Math.max(imageFlickable.width / width, imageFlickable.height / height);
                        pinchArea.minScale = scale
                        prevScale = scale
                    }

                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    cache: false
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

            PinchArea {
                id: pinchArea

                property real minScale: 1.0
                property real maxScale: Math.max(minScale, 1.0);

                anchors.fill: parent
                enabled: imagePreview.status === Image.Ready
                pinch.target: imagePreview
                pinch.minimumScale: minScale * 0.5 // This is to create "bounce back effect"
                pinch.maximumScale: maxScale * 1.5 // when over zoomed

                onPinchFinished: {
                    imageFlickable.returnToBounds()
                    if (imagePreview.scale < pinchArea.minScale) {
                        bounceBackAnimation.to = pinchArea.minScale
                        bounceBackAnimation.start()
                    }
                    else if (imagePreview.scale > pinchArea.maxScale) {
                        bounceBackAnimation.to = pinchArea.maxScale
                        bounceBackAnimation.start()
                    }
                }

                NumberAnimation {
                    id: bounceBackAnimation
                    target: imagePreview
                    duration: 250
                    property: "scale"
                    from: imagePreview.scale
                }
            }
        }

        BusyIndicator {
            anchors.centerIn: parent;
            width: constant.graphicSizeLarge;
            height: constant.graphicSizeLarge;
            running: true;
            visible: imagePreview.status === Image.Loading;
            platformInverted: tbsettings.whiteTheme;
        }

        Rectangle {
            id: mask;
            width: Math.max(parent.width, parent.height);
            height: width;
            anchors.centerIn: parent;
            border {
                width: mask.width - imageFlickable.width;
                color: "#A00A0A0A"
            }
            color: "transparent";
        }

        Rectangle {
            id: frame;
            anchors.fill: imageFlickable;
            border { width: 2; color: "white"; }
            color: "transparent";
        }
    }
}
