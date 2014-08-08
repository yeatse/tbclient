import QtQuick 1.0
import com.nokia.symbian 1.0
import "../Floor" as Floor
import "../Component" as Comp
import "../Silica" as Silica
import "../../js/main.js" as Script

Item {
    id: root;

    width: ListView.view.width;
    height: ListView.view.height;

    Keys.onUpPressed: view.contentY = Math.max(0, view.contentY-view.height);
    Keys.onDownPressed: view.contentY = Math.min(view.contentHeight-view.height,
                                                 view.contentY+view.height);
    Component.onCompleted: coldDown.start();

    property int totalPage: 0;
    property int currentPage: 1;
    property bool loading: false;

    function scrollToTop(){
        view.scrollToTop();
    }

    function getlist(option){
        option = option||"renew";
        var opt = {
            page: root,
            model: repeater.model,
            tid: threadId,
            kw: internal.forum.name,
            pic_id: pic_id
        }
        if (option == "renew"){
            opt.renew = true;
            opt.pn = 1;
        } else {
            opt.pn = currentPage + 1;
        }
        loading = true;
        function s(count){
            loading = false;
            ListView.view.model.setProperty(index, "comment_amount", count);
        }
        function f(err){
            loading = false;
            signalCenter.showMessage(err);
        }
        Script.getPicComment(opt, s, f);
    }

    Silica.SilicaFlickable {
        id: view;
        anchors.fill: parent;
        contentWidth: root.width;
        contentHeight: contentCol.height;
        flickableDirection: Flickable.VerticalFlick;
        Column {
            id: contentCol;
            width: parent.width;
            Item {
                width: root.width;
                height: Math.max(constant.thumbnailSize, width / pic_ratio);
                Image {
                    id: preview;
                    anchors.fill: parent;
                    asynchronous: true;
                    sourceSize.width: width;
                    fillMode: Image.PreserveAspectFit;
                    source: url;
                }
                BusyIndicator {
                    anchors.centerIn: parent;
                    //platformInverted: tbsettings.whiteTheme;
                    running: true;
                    visible: preview.status == Image.Loading;
                    width: constant.graphicSizeLarge;
                    height: constant.graphicSizeLarge;
                }
                MouseArea {
                    anchors.fill: parent;
                    onClicked: signalCenter.viewImage(url)
                }
            }
            Rectangle {
                width: parent.width;
                height: constant.graphicSizeLarge;
                color: "#A0463D3B";
                visible: descr != "";
                Text {
                    anchors { fill: parent; margins: constant.paddingLarge; }
                    font: constant.labelFont;
                    color: "white";
                    horizontalAlignment: Text.AlignLeft;
                    verticalAlignment: Text.AlignVCenter;
                    elide: Text.ElideRight;
                    text: descr;
                }
            }
            ListHeading {
                //platformInverted: tbsettings.whiteTheme;
                Text {
                    anchors {
                        left: parent.paddingItem.left;
                        top: parent.paddingItem.top;
                    }
                    font: constant.subTitleFont;
                    color: constant.colorTextSelection;
                    text: user_name;
                }
                ListItemText {
                    anchors.fill: parent.paddingItem;
                    text: qsTr("Comments")+"(%1)".arg(comment_amount);
                    //platformInverted: parent.platformInverted;
                    role: "Heading";
                }
            }
            Repeater {
                id: repeater;
                model: ListModel {}
                Floor.FloorDelegate {}
            }
            Comp.FooterItem {
                visible: repeater.count > 0;
                enabled: currentPage < totalPage && !loading;
                onClicked: getlist("next");
            }
            Comp.AbstractItem {
                visible: repeater.count == 0;
                Text {
                    anchors.centerIn: parent;
                    text: qsTr("No comments");
                    font: constant.labelFont;
                    color: constant.colorMid;
                }
            }
        }
    }

    Timer {
        id: coldDown;
        interval: 500;
        onTriggered: getlist();
    }
}
