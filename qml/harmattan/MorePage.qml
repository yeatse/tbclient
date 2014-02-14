import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"

MyPage {
    id: page;

    title: qsTr("More");

    tools: ToolBarLayout {
        BackButton {}
    }

    function init(){
        var dict = [[qsTr("Tabs"),"tabs","signalCenter.enterThread()"],
                    [qsTr("Browser"),"internet","signalCenter.openBrowser(\"http://m.baidu.com\")"],
                    [qsTr("Square"),"square","pageStack.push(Qt.resolvedUrl(\"Explore/SquarePage.qml\"))"],
                    [qsTr("Accounts"),"sign","pageStack.push(Qt.resolvedUrl(\"AccountPage.qml\"))"],
                    [qsTr("Settings"),"settings","pageStack.push(Qt.resolvedUrl(\"SettingsPage.qml\"))"],
                    [qsTr("About"),"info","pageStack.push(Qt.resolvedUrl(\"AboutPage.qml\"))"]];
        dict.forEach(function(value){
                         view.model.append({name:value[0],file:value[1],script:value[2]});
                     });
    }

    ListView {
        id: view;
        anchors.fill: parent;
        model: ListModel {}
        header: ViewHeader {
            title: page.title;
            Rectangle {
                width: parent.width;
                height: 400;
                anchors.bottom: parent.top;
                color: "black";
            }
        }
        delegate: AbstractItem {
            id: root;
            onClicked: eval(script);
            Image {
                id: iconImg;
                anchors {
                    left: root.paddingItem.left;
                    verticalCenter: parent.verticalCenter;
                }
                source: "../gfx/more_"+file+".svg"
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
                source: privateStyle.imagePath("qtg_graf_drill_down_indicator", tbsettings.whiteTheme);
                sourceSize.width: platformStyle.graphicSizeSmall;
                sourceSize.height: platformStyle.graphicSizeSmall;
            }
        }
    }

    ScrollDecorator { flickableItem: view; platformInverted: tbsettings.whiteTheme; }

    Component.onCompleted: init();

    // For keypad
    onStatusChanged: {
        if (status === PageStatus.Active){
            view.forceActiveFocus();
        }
    }
}
