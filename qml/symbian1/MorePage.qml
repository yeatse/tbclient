import QtQuick 1.0
import com.nokia.symbian 1.0
import "Component"

MyPage {
    id: page;

    title: qsTr("More");

    tools: ToolBarLayout {
        BackButton {}
    }

    function init(){
        var dict = [[qsTr("Tabs"),"folder-empty","signalCenter.enterThread()"],
                    [qsTr("Browser"),"browser","signalCenter.openBrowser(\"http://m.baidu.com\")"],
                    [qsTr("Square"),"gallery","pageStack.push(Qt.resolvedUrl(\"Explore/SquarePage.qml\"))"],
                    [qsTr("Accounts"),"accounts","pageStack.push(Qt.resolvedUrl(\"AccountPage.qml\"))"],
                    [qsTr("Settings"),"settings","pageStack.push(Qt.resolvedUrl(\"SettingsPage.qml\"))"],
                    [qsTr("About"),"user-guide","pageStack.push(Qt.resolvedUrl(\"AboutPage.qml\"))"]];
        dict.forEach(function(value){
                         view.model.append({name:value[0],file:value[1],script:value[2]});
                     });
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
    }

    ListView {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        model: ListModel {}
        delegate: AbstractItem {
            id: root;
            onClicked: eval(script);
            Image {
                id: iconImg;
                anchors {
                    left: root.paddingItem.left;
                    top: root.paddingItem.top;
                    bottom: root.paddingItem.bottom;
                }
                width: height;
                sourceSize: Qt.size(width, height);
                source: "gfx/icon-l-"+file+".png"
            }
            Text {
                anchors {
                    left: iconImg.right;
                    leftMargin: constant.paddingMedium;
                    verticalCenter: parent.verticalCenter;
                }
                font: constant.titleFont;
                color: constant.colorLight;
                text: name;
            }
            Image {
                id: subItemIcon;
                anchors {
                    right: parent.right;
                    rightMargin: privateStyle.scrollBarThickness;
                    verticalCenter: parent.verticalCenter;
                }
                source: privateStyle.imagePath("qtg_graf_drill_down_indicator");
                sourceSize.width: platformStyle.graphicSizeSmall;
                sourceSize.height: platformStyle.graphicSizeSmall;
            }
        }
    }

    ScrollDecorator {
        flickableItem: view; //platformInverted: tbsettings.whiteTheme;
    }

    Component.onCompleted: init();

    // For keypad
    onStatusChanged: {
        if (status === PageStatus.Active){
            view.forceActiveFocus();
        }
    }
}
