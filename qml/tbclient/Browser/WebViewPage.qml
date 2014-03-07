// Deprecated

import QtQuick 1.1
import com.nokia.symbian 1.1
import QtWebKit 1.0
import "../Component"

MyPage {
    id: page;

    property alias url: webView.url;

    title: webView.title;

    tools: ToolBarLayout {
        BackButton {}
        ToolButtonWithTip {
            toolTipText: loading ? webView.stop.toolTip : webView.reload.toolTip;
            iconSource: loading ? "../gfx/tb_close_stop"+constant.invertedString+".svg" : "toolbar-refresh";
            enabled: loading ? webView.stop.enabled : webView.reload.enabled;
            onClicked: loading ? webView.stop.trigger() : webView.reload.trigger();
        }
        ToolButtonWithTip {
            toolTipText: qsTr("Home page");
            iconSource: "../gfx/home_sousuo.png";
            onClicked: homeMenu.open();
        }
        ToolButtonWithTip {
            toolTipText: qsTr("Menu");
            iconSource: "toolbar-menu";
            onClicked: mainMenu.open();
        }
    }

    WebHomeMenu { id: homeMenu; }
    WebMainMenu { id: mainMenu; }

    Flickable {
        id: flickable

        anchors.fill: parent;

        // Properties
        property alias title: webView.title
        property alias progress: webView.progress
        property alias url: webView.url
        property alias back: webView.back
        property alias reload: webView.reload
        property alias stop: webView.stop
        property alias forward: webView.forward
        property alias icon: webView.icon
        property bool loading: webView.progress != 1.0
        property bool zoomActive: false

        // Signals
        signal gotFocus
        signal lostFocus
        signal urlChanged(string urlString)
        signal iconChanged()

        // Functions
        function changeUrl(urlString) {
            if(urlString)
                webView.setUrl(urlString);
        }

        width: parent.width
        contentWidth: Math.max(parent.width,webView.width)
        contentHeight: Math.max(parent.height,webView.height)
        onWidthChanged: {
            // Expand (but not above 1:1) if otherwise would be smaller that available width.
            if (width > webView.width*webView.contentsScale && webView.contentsScale < 1.0)
                webView.contentsScale = width / webView.width * webView.contentsScale;
        }

        pressDelay: 200
        onFocusChanged: { if ( focus ) webView.focus = true; } // Force focus on "webView" when received
        onMovementStarted: webView.renderingEnabled = false;
        onMovementEnded: webView.renderingEnabled = true;

        boundsBehavior: Flickable.StopAtBounds;
        PinchArea {
            id: pinchArea
            anchors.fill: parent
            property bool pinchDragged:false

            onPinchStarted: {
                webView.renderingEnabled=false
                flickable.zoomActive=true
            }

            onPinchUpdated: {
                webView.doPinchZoom(pinch.scale/pinch.previousScale,pinch.center,pinch.previousCenter)
            }

            onPinchFinished: {

                if(flickable.contentX<0 || flickable.contentY<0){
                    var sc = webView.contentsScale
                    if(webView.contentsScale*webView.width<flickable.width){
                        sc=flickable.width/(webView.width/webView.contentsScale)
                    }
                    var vx=Math.max(0,flickable.contentX)+(flickable.width/2)
                    var vy=Math.max(0,flickable.contentY)+(flickable.height/2)
                    // doZoom will reset zoomActive to false and renderingEnabled to true
                    webView.doZoom(sc,vx,vy);
                }else{
                    webView.renderingEnabled=true;
                    flickable.zoomActive=false;
                }

            }

            WebView {
                id: webView
                objectName: "webView"
                transformOrigin: Item.TopLeft

                javaScriptWindowObjects: QtObject {
                    WebView.windowObjectName: "scroller";
                    function scrollTo(xPos, yPos){
                        flickable.contentX = xPos;
                        flickable.contentY = yPos;
                    }
                }

                settings {
                    javascriptCanOpenWindows: true;
                    javascriptCanAccessClipboard: true;
                    offlineStorageDatabaseEnabled: true;
                    offlineWebApplicationCacheEnabled: true;
                    localStorageDatabaseEnabled: true;
                }

                // Set the URL for this WebView
                function setUrl(urlString) { this.url = urlString; }

                // Execute the Zooming
                function doZoom(zoom,centerX,centerY)
                {
                    if (centerX) {
                        var sc = zoom/contentsScale;
                        scaleAnim.to = zoom;
                        flickVX.from = flickable.contentX
                        flickVX.to = Math.max(0,Math.min(centerX-flickable.width/2,webView.width*sc-flickable.width))
                        finalX.value = flickVX.to
                        flickVY.from = flickable.contentY
                        flickVY.to = Math.max(0,Math.min(centerY-flickable.height/2,webView.height*sc-flickable.height))
                        finalY.value = flickVY.to
                        quickZoom.start()
                    }
                }
                // Calculates new contentX and contentY for flickable and contentsScale for webview
                function doPinchZoom(zoom,center,centerPrev)
                {
                    var sc=zoom*contentsScale
                    if(sc<=10 ){
                        //calculate contentX and contentY so webview moves along with the pinch
                        flickable.contentX=(center.x*zoom)-(center.x-flickable.contentX)+(centerPrev.x-center.x)
                        flickable.contentY=(center.y*zoom)-(center.y-flickable.contentY)+(centerPrev.y-center.y)
                        contentsScale=sc
                    }

                }
                smooth: false // We don't want smooth scaling, since we only scale during (fast) transitions
                focus: true

                preferredWidth: flickable.width
                preferredHeight: flickable.height
                contentsScale: 1

                // [Signal Handling]
                Keys.onLeftPressed: { webView.contentsScale -= 0.1; }
                Keys.onRightPressed: { webView.contentsScale += 0.1; }
//                onAlert: signalCenter.createQueryDialog(qsTr("Alert"),message,qsTr("OK"),"");
                onFocusChanged: {
                    if ( focus == true ) { flickable.gotFocus(); }
                    else { flickable.lostFocus(); }
                }
                onContentsSizeChanged: { webView.contentsScale = Math.min(1,flickable.width / contentsSize.width); }
                onUrlChanged: {
                    // Reset Content to the TopLeft Corner
                    flickable.contentX = 0
                    flickable.contentY = 0
                    flickable.returnToBounds();
                    webView.focus = true;
                    if ( url != null ) {
                        flickable.urlChanged(url.toString());
                    }
                }
                onDoubleClick: {
                    var zf=2.0
                    // if zoomed go back to screen width
                    if(webView.contentsScale*webView.width>flickable.width){
                        zf=flickable.width/(webView.width/webView.contentsScale)
                        doZoom(zf,clickX*zf,clickY*zf)
                        // try to do heuristic zoom with maximum 2.5x
                    }else if (!heuristicZoom(clickX, clickY, 2.5)) {
                        // if no heuristic zoom found, zoom to 2.0x
                        doZoom(zf,clickX*zf,clickY*zf)
                    }

                }
                onIconChanged: { flickable.iconChanged(); }
                onLoadStarted: loading = true;
                onLoadFailed: { webView.stop.trigger(); loading = false; }
                onLoadFinished: {
                    loading = false;
                    evaluateJavaScript("window.scrollTo = window.scroller.scrollTo;");
                }

                onZoomTo: { doZoom(zoom,centerX,centerY); }
                // [/Signal Handling]

                SequentialAnimation {
                    id: quickZoom

                    PropertyAction {
                        target: webView
                        property: "renderingEnabled"
                        value: false
                    }
                    ParallelAnimation {
                        NumberAnimation {
                            id: scaleAnim
                            target: webView; property: "contentsScale";
                            // the to property is set before calling
                            easing.type: Easing.Linear; duration: 200;
                        }
                        NumberAnimation {
                            id: flickVX
                            target: flickable; property: "contentX";
                            easing.type: Easing.Linear; duration: 200;
                            from: 0 // set before calling
                            to: 0 // set before calling
                        }
                        NumberAnimation {
                            id: flickVY
                            target: flickable; property: "contentY";
                            easing.type: Easing.Linear; duration: 200;
                            from: 0 // set before calling
                            to: 0 // set before calling
                        }
                    }
                    // Have to set the contentXY, since the above 2
                    // size changes may have started a correction if
                    // contentsScale < 1.0.
                    PropertyAction {
                        id: finalX
                        target: flickable; property: "contentX";
                        value: 0 // set before calling
                    }
                    PropertyAction {
                        id: finalY
                        target: flickable; property: "contentY";
                        value: 0 // set before calling
                    }
                    PropertyAction {
                        target: webView; property: "renderingEnabled";
                        value: true
                    }
                    PropertyAction {
                        target: flickable; property: "zoomActive";
                        value: false
                    }
                }
            }
        }
    }

    // For keypad
    onStatusChanged: {
        if (status === PageStatus.Active){
            webView.forceActiveFocus();
        }
    }
    Connections {
        target: platformPopupManager;
        onPopupStackDepthChanged: {
            if (platformPopupManager.popupStackDepth === 0
                    && page.status === PageStatus.Active){
                webView.forceActiveFocus();
            }
        }
    }
    Keys.onPressed: {
        switch (event.key){
        case Qt.Key_M: mainMenu.open(); event.accepted = true; break;
        }
    }
}
