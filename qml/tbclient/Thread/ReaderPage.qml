import QtQuick 1.1
import com.nokia.symbian 1.1
import QtWebKit 1.0
import "../Component"

MyPage {
    id: page;

    property int currentIndex: 0;
    property alias listModel: ;

    ListHeading {
        id: viewHeader;
        platformInverted: tbsettings.whiteTheme;
        ListItemText {
            anchors.fill: parent.paddingItem;
            role: "Heading";
            platformInverted: parent.platformInverted;
        }
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
                implicitWidth: ListView.view.width;
                implicitHeight: ListView.view.height;

                Flickable {
                    id: flickable;
                    anchors.fill: parent;
                    clip: true;
                    contentWidth: webView.width;
                    contentHeight: webView.height;

                    WebView {
                        id: webView;
                        preferredWidth: root.width;
                        preferredHeight: root.height;
                        settings {
                            autoLoadImages: tbsettings.showImage;
                            defaultFixedFontSize: tbsettings.fontSize;
                            defaultFontSize: tbsettings.fontSize;
                        }
                        onLoadStarted: loading = true;
                        onLoadFinished: loading = false;
                        onLoadFailed: loading = false;
                    }
                }
                ScrollDecorator { flickableItem: flickable; platformInverted: tbsettings.whiteTheme; }
            }
        }
    }

    function setSource(){
    }
}
