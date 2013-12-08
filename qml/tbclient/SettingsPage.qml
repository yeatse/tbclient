import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "Silica"

MyPage {
    id: page;

    title: qsTr("Settings");
    tools: ToolBarLayout {
        BackButton {}
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
        onClicked: view.scrollToTop();
    }

    SilicaFlickable {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        contentWidth: view.width;
        contentHeight: contentCol.height;

        Column {
            id: contentCol;
            width: parent.width;
            SelectionListItem {
                title: browserSelector.titleText;
                subTitle: browserSelector.selectedIndex >= 0
                          ? browserSelector.model.get(browserSelector.selectedIndex).modelData
                          : "";
                onClicked: browserSelector.open();
                SelectionDialog {
                    id: browserSelector;
                    titleText: qsTr("Default browser")
                    model: ListModel {}
                    Binding {
                        id: browserIndexBinding;
                        target: browserSelector;
                        property: "selectedIndex";
                        value: {
                            for (var i=0; i<browserSelector.model.count; i++){
                                if (browserSelector.model.get(i).name === tbsettings.browser)
                                    return i;
                            }
                            return 0;
                        }
                        when: false;
                    }
                    Component.onCompleted: {
                        var dict = [["",qsTr("Built-in")],
                                    ["System",qsTr("System browser")],
                                    ["UC",qsTr("UC")],
                                    ["UC International",qsTr("UC International")],
                                    ["Opera",qsTr("Opera Mobile")]]
                        dict.forEach(function(value){
                                         model.append({name: value[0], modelData: value[1]});
                                     });
                        browserIndexBinding.when = true;
                    }
                    onAccepted: tbsettings.browser = model.get(selectedIndex).name;
                }
            }
        }
    }
}
