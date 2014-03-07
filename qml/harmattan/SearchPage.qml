import QtQuick 1.1
import com.nokia.extras 1.1
import com.nokia.meego 1.1
import "Component"
import "../js/main.js" as Script

MyPage {
    id: page;

    property bool firstStart: true;

    title: qsTr("Search");
    loading: tabGroup.currentTab.loading;

    tools: ToolBarLayout {
        BackButton {}
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
    }
    Item {
        id: searchItem;
        anchors.top: viewHeader.bottom;
        width: parent.width;
        height: constant.graphicSizeLarge;
        SearchInput {
            id: searchInput;
            anchors {
                left: parent.left; leftMargin: constant.paddingLarge;
                right: searchBtn.left; rightMargin: constant.paddingMedium;
                verticalCenter: parent.verticalCenter;
            }
            placeholderText: qsTr("Tap to search");
            onCleared: pageStack.pop(undefined, true);
            onTypeStopped: {
                if (tabGroup.currentTab == suggestView){
                    if (text != "") suggestView.get();
                    else suggestView.model.clear();
                } else if (tabGroup.currentTab == searchView){
                    if (text != "") searchView.get();
                    else searchView.model.clear();
                }
            }
        }
        Button {
            id: searchBtn;
            anchors {
                right: parent.right; rightMargin: constant.paddingLarge;
                verticalCenter: parent.verticalCenter;
            }
            platformStyle: ButtonStyle { buttonWidth: buttonHeight; }
            iconSource: "image://theme/icon-m-toolbar-mediacontrol-play"+(theme.inverted?"-white":"");
            onClicked: {
                if (tabGroup.currentTab == suggestView){
                    if (searchInput.text != "")
                        signalCenter.enterForum(searchInput.text);
                } else if (tabGroup.currentTab == searchView){
                    if (searchInput.text != "")
                        searchView.get();
                    else
                        searchView.model.clear();
                }
            }
        }
    }
    ButtonRow {
        id: tabRow;
        anchors.top: searchItem.bottom;
        width: parent.width;
        style: TabButtonStyle {}
        TabButton {
            text: qsTr("Search tieba");
            tab: suggestView;
            onClicked: {
                if (searchInput.text == ""){
                    suggestView.model.clear();
                } else if (suggestView.searchText != searchInput.text){
                    suggestView.get();
                }
            }
        }
        TabButton {
            text: qsTr("Search posts");
            tab: searchView;
            onClicked: {
                if (searchInput.text == "")
                    searchView.model.clear();
                else if (searchInput.text != searchView.searchText)
                    searchView.get();
            }
        }
        TabButton {
            text: qsTr("Search web");
            onClicked: {
                var url = "http://m.baidu.com/"
                if (searchInput.text.length > 0)
                    url += "s?word="+searchInput.text;
                signalCenter.openBrowser(url);
            }
        }
    }
    TabGroup {
        id: tabGroup;
        anchors {
            left: parent.left; right: parent.right;
            top: tabRow.bottom; bottom: parent.bottom;
        }
        clip: true;
        currentTab: suggestView;
        ListView {
            id: suggestView;
            property string searchText;
            property bool loading: false;
            function get(){
                searchText = searchInput.text;
                var opt = { model: suggestView.model, q: searchText };
                loading = true;
                function s(){ loading = false; }
                function f(err){ loading = false; signalCenter.showMessage(err); }
                Script.forumSuggest(opt, s, f);
            }
            anchors.fill: parent;
            model: ListModel {}
            delegate: Item {
                width: suggestView.width;
                height: constant.graphicSizeLarge;
                opacity: mouseArea.pressed ? 0.7 : 1;
                Text {
                    anchors { fill: parent; margins: constant.paddingLarge; }
                    verticalAlignment: Text.AlignVCenter;
                    elide: Text.ElideRight;
                    font: constant.titleFont;
                    color: constant.colorLight;
                    text: modelData;
                }
                MouseArea {
                    id: mouseArea;
                    anchors.fill: parent;
                    onClicked: signalCenter.enterForum(modelData);
                }
            }
        }
        ListView {
            id: searchView;
            property string searchText;
            property bool loading: false;
            property bool hasMore: false;
            property int currentPage: 1;
            function get(option){
                if (option != "next")
                    searchText = searchInput.text;
                loading = true;
                var opt = {
                    word: searchText,
                    page: searchView,
                    model: searchView.model
                }
                option = option || "renew";
                if (option === "renew"){
                    opt.renew = true;
                    currentPage = 1;
                    opt.pn = 1;
                } else {
                    opt.pn = currentPage + 1;
                }
                var s = function(){ loading = false; }
                var f = function(err){ loading = false; signalCenter.showMessage(err); }
                Script.searchPost(opt, s, f);
            }
            anchors.fill: parent;
            model: ListModel{}
            delegate: searchDelegate;
            footer: FooterItem {
                visible: searchView.count > 0;
                enabled: !searchView.loading && searchView.hasMore && searchView.searchText != ""
                onClicked: searchView.get("next");
            }
            Component {
                id: searchDelegate;
                AbstractItem {
                    id: root;
                    implicitHeight: contentCol.height + constant.paddingLarge*2;
                    onClicked: signalCenter.createEnterThreadDialog(title, is_floor, pid, tid, fname, true);
                    Column {
                        id: contentCol;
                        anchors {
                            left: root.paddingItem.left; right: root.paddingItem.right;
                            top: root.paddingItem.top;
                        }
                        spacing: constant.paddingSmall;
                        Text {
                            width: parent.width;
                            wrapMode: Text.Wrap;
                            text: content;
                            color: constant.colorLight;
                            font: constant.titleFont;
                            textFormat: Text.PlainText;
                        }
                        Item {
                            width: parent.width;
                            implicitHeight: label.height+constant.paddingMedium*2+5;
                            BorderImage {
                                anchors.fill: parent;
                                asynchronous: true;
                                source: "gfx/retweet_bg"+constant.invertedString;
                                border { left: 32; right: 10; top: 15; bottom: 10; }
                            }
                            Text {
                                id: label;
                                anchors {
                                    left: parent.left; leftMargin: constant.paddingMedium;
                                    top: parent.top; topMargin: constant.paddingMedium+5;
                                    right: parent.right; rightMargin: constant.paddingMedium;
                                }
                                text: title;
                                font: constant.labelFont;
                                color: constant.colorMid;
                                wrapMode: Text.WrapAnywhere;
                                elide: Text.ElideRight;
                                maximumLineCount: 1;
                                textFormat: Text.PlainText;
                            }
                        }
                        Item {
                            width: parent.width;
                            height: childrenRect.height;
                            Text {
                                font: constant.subTitleFont;
                                color: constant.colorMid;
                                text: fname + qsTr("Bar");
                            }
                            Text {
                                anchors.right: parent.right;
                                font: constant.subTitleFont;
                                color: constant.colorMid;
                                text: time;
                            }
                        }
                    }
                }
            }
        }
    }

    // For keypad
    onStatusChanged: {
        if (status === PageStatus.Active){
            searchInput.forceActiveFocus();
            if (firstStart){
                firstStart = false;
                searchInput.platformOpenSoftwareInputPanel();
            }
        }
    }
}
