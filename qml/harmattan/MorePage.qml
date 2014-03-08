import QtQuick 1.1
import com.nokia.meego 1.1
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
        delegate: SettingsItem {
            subItemIconVisible: true;
            title: name;
            iconSource: "image://theme/icon-l-"+file;
            onClicked: eval(script)
        }
    }

    ScrollDecorator { flickableItem: view; }

    Component.onCompleted: init();
}
