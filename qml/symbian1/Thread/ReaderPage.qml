import QtQuick 1.0
import com.nokia.symbian 1.0
import QtWebKit 1.0
import "../Component"
import "../../js/Utils.js" as Utils

MyPage {
    id: page;

    property int currentIndex: -1;
    property alias listModel: view.model;
    property variant parentView: null;
    property bool firstStart: true;

    tools: ToolBarLayout {
        BackButton {}
        ToolButtonWithTip {
            toolTipText: qsTr("Prev");
            text: qsTr("Prev");
            enabled: !view.atYBeginning;
            onClicked: view.decrementCurrentIndex();
        }
        ToolButtonWithTip {
            toolTipText: qsTr("Next");
            text: qsTr("Next");
            enabled: !view.atYEnd;
            onClicked: view.incrementCurrentIndex();
        }
    }

    loading: view.currentItem != null && view.currentItem.loading;

    ListHeading {
        id: viewHeader;
        //platformInverted: tbsettings.whiteTheme;
        z: 10;
        ListItemText {
            anchors.fill: parent.paddingItem;
            role: "SubTitle";
            //platformInverted: parent.platformInverted;
            text: view.currentItem ? listModel.get(view.currentIndex).floor+"#" : "";
        }
        ListItemText {
            anchors.fill: parent.paddingItem;
            role: "Heading";
            //platformInverted: parent.platformInverted;
            text: view.currentItem ? listModel.get(view.currentIndex).authorName : "";
        }
    }

    Rectangle {
        id: bg;
        anchors.fill: parent;
        color: "#F3ECDC";
    }

    ListView {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        interactive: false;
        highlightRangeMode: ListView.StrictlyEnforceRange;
        highlightMoveDuration: 400;
        snapMode: ListView.SnapOneItem;
        delegate: articleComp;
        Component {
            id: articleComp;
            Item {
                id: root;

                property bool loading: false;
                width: view.width;
                height: view.height;

                Keys.onPressed: {
                    if (!event.isAutoRepeat) {
                        switch (event.key) {
                        case Qt.Key_Up: {
                            if (symbian.listInteractionMode != Symbian.KeyNavigation) {
                                symbian.listInteractionMode = Symbian.KeyNavigation
                                ListView.view.positionViewAtIndex(index, ListView.Beginning)
                            } else
                                up();
                            event.accepted = true
                            break
                        }
                        case Qt.Key_Down: {
                            if (symbian.listInteractionMode != Symbian.KeyNavigation) {
                                symbian.listInteractionMode = Symbian.KeyNavigation
                                ListView.view.positionViewAtIndex(index, ListView.Beginning)
                            } else
                                down();
                            event.accepted = true
                            break
                        }
                        default: {
                            event.accepted = false
                            break
                        }
                        }
                    }
                    if (event.key == Qt.Key_Up || event.key == Qt.Key_Down)
                        symbian.privateListItemKeyNavigation(ListView.view)
                }

                function up(){
                    if (flickable.contentY <= 0){
                        if (!ListView.view.atYBeginning)
                            ListView.view.decrementCurrentIndex();
                    } else {
                        flickable.contentY = Math.max(0, flickable.contentY-flickable.height);
                    }
                }
                function down(){
                    if (flickable.contentY >= flickable.contentHeight-flickable.height){
                        if (!ListView.view.atYEnd)
                            ListView.view.incrementCurrentIndex();
                    } else {
                        flickable.contentY = Math.min(flickable.contentHeight-flickable.height,
                                                      flickable.contentY+flickable.height);
                    }
                }

                Flickable {
                    id: flickable;
                    anchors.fill: parent;
                    contentWidth: webView.width;
                    contentHeight: webView.height;
                    boundsBehavior: Flickable.StopAtBounds;

                    WebView {
                        id: webView;
                        preferredWidth: root.width;
                        preferredHeight: root.height;
                        settings {
                            defaultFixedFontSize: tbsettings.fontSize;
                            defaultFontSize: tbsettings.fontSize;
                        }
                        onLoadStarted: loading = true;
                        onLoadFinished: loading = false;
                        onLoadFailed: loading = false;

                        javaScriptWindowObjects: QtObject {
                            WebView.windowObjectName: "clickListener";
                            function onClick(hrefValue){
                                signalCenter.linkClicked(hrefValue);
                            }
                        }

                        Component.onCompleted: coldDown.start();
                        Timer {
                            id: coldDown;
                            interval: 200;
                            onTriggered: {
                                var res = "";
                                for (var i=0; i<content.count; i++){
                                    var m = content.get(i);
                                    switch (m.type){
                                    case "Text":
                                        if (m.format === 0) res += m.text.replace(/\n/g, "<br/>");
                                        else res += m.text;
                                        break;
                                    case "Image":
                                        if (tbsettings.showImage){
                                            res += "<img src=\""+m.format+"\"/>";
                                        } else {
                                            res += "<a href=\"img:"+m.format+"\">"+m.format+"</a>";
                                        }
                                        break;
                                    case "Audio":
                                        break;
                                    }
                                    res += "<br/>";
                                }
                                webView.html = res;
                                webView.evaluateJavaScript("document.body.style.background=\"#F3ECDC\"");
                                webView.evaluateJavaScript("\
document.onclick=function(ev){\
ev=ev||window.event;\
var target=ev.target||ev.srcElement;\
var tagName=target.tagName.toLowerCase();\
if(tagName=='a'){window.clickListener.onClick(target.href)}}");
                            }
                        }
                    }
                }
                ScrollDecorator {
                    flickableItem: flickable; //platformInverted: tbsettings.whiteTheme;
                }
            }
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active){
            if (firstStart){
                firstStart = false;
                view.positionViewAtIndex(currentIndex, ListView.Beginning);
            }
            view.forceActiveFocus();
        } else if (status === PageStatus.Deactivating){
            if (parentView)
                parentView.positionViewAtIndex(view.currentIndex, ListView.Visible);
        }
    }
}
