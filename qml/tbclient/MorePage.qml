import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "WebPageMenu"

MyPage {
    id: page;

    title: qsTr("More");

    tools: ToolBarLayout {
        BackButton {}
    }

    function init(){
        var dict = [[qsTr("Tabs"),"signalCenter.enterThread()"],
                    [qsTr("Browser"),"signalCenter.openBrowser(\"http://m.baidu.com\")"],
                    [qsTr("Square"),"pageStack.push(Qt.resolvedUrl(\"Explore/SquarePage.qml\"))"],
                    [qsTr("Accounts"),""],
                    [qsTr("Settings"),"pageStack.push(Qt.resolvedUrl(\"SettingsPage.qml\"))"],
                    [qsTr("About"),""]];
        dict.forEach(function(value){
                         gridModel.append({name:value[0],script:value[1]});
                     });
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
    }

    Flickable {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        contentWidth: parent.width;
        contentHeight: grid.height;
        Grid {
            id: grid;
            width: parent.width;
            columns: screen.width > screen.height ? 5 : 3;
            Repeater {
                model: ListModel { id: gridModel; }
                WebHomeDelegate {
                    width: grid.width / grid.columns;
                    iconSource: "../gfx/more_"+(index+1)+".jpg";
                    title: name;
                    onClicked: eval(script);
                }
            }
        }
    }

    Component.onCompleted: init();
}
