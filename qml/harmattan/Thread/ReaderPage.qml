import QtQuick 1.1
import com.nokia.meego 1.1
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
        ToolIcon {
            platformIconId: "toolbar-up";
            enabled: !view.atYBeginning;
            onClicked: view.decrementCurrentIndex();
        }
        ToolIcon {
            platformIconId: "toolbar-down"
            enabled: !view.atYEnd;
            onClicked: view.incrementCurrentIndex();
        }
    }

    loading: view.currentItem != null && view.currentItem.loading;

    ViewHeader {
        id: viewHeader;
        title: {
            if (view.currentItem){
                var d = listModel.get(view.currentIndex);
                return d.floor+"#    "+d.authorName;
            } else {
                return "";
            }
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
                implicitWidth: view.width;
                implicitHeight: view.height;

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
                ScrollDecorator { flickableItem: flickable;}
            }
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active){
            if (firstStart){
                firstStart = false;
                view.positionViewAtIndex(currentIndex, ListView.Beginning);
            }
        } else if (status === PageStatus.Deactivating){
            if (parentView)
                parentView.positionViewAtIndex(view.currentIndex, ListView.Visible);
        }
    }
}
