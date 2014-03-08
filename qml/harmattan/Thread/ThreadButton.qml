import QtQuick 1.1
import com.nokia.meego 1.1

Item {
    id: root;

    property Item tab;
    // Don't use checked because it has bugs on N9
    property bool active: internal.tabGroup !== null && internal.tabGroup.currentTab === tab;
    signal clicked;

    width: parent.width / parent.children.length;
    height: parent.height;

    QtObject {
        id: internal;

        property Item tabGroup: findParent(tab, "currentTab");
        function click(){
            root.clicked();
            if (internal.tabGroup){
                if (internal.tabGroup.currentTab == tab){
                    tab.positionAtTop();
                } else {
                    internal.tabGroup.currentTab = tab;
                }
            }
        }
        function findParent(child, propertyName) {
            if (!child)
                return null
            var next = child.parent
            while (next && !next.hasOwnProperty(propertyName))
                next = next.parent
            return next
        }
        function getMask(){
            if (tab.loading)
                return busyIndicator;
            if (sectionMouseArea.pressed)
                return pressingIndicator;
            if (!root.checked)
                return inactiveIndicator;
        }
    }

    Text {
        anchors { fill: parent; margins: constant.paddingSmall; }
        elide: Text.ElideRight;
        horizontalAlignment: Text.AlignHCenter;
        verticalAlignment: Text.AlignVCenter;
        textFormat: Text.PlainText;
        wrapMode: Text.WrapAnywhere;
        maximumLineCount: 1;
        text: tab.title;
        font: constant.labelFont;
        color: "white";
    }

    Loader {
        anchors.fill: parent;
        sourceComponent: internal.getMask();
        Component {
            id: busyIndicator;
            Rectangle {
                id: indBg;
                anchors.fill: parent;
                color: "black";
                opacity: 0;
                BusyIndicator {
                    opacity: 1;
                    anchors.centerIn: parent;
                    running: true;
                    platformStyle.inverted: true;
                }
                Component.onCompleted: PropertyAnimation {
                    target: indBg;
                    property: "opacity";
                    from: 0;
                    to: 0.75;
                    duration: 250;
                }
            }
        }
        Component {
            id: pressingIndicator;
            Rectangle {
                anchors.fill: parent;
                color: "black";
                opacity: 0.5;
            }
        }
        Component {
            id: inactiveIndicator;
            Rectangle {
                anchors.fill: parent;
                color: "black";
                opacity: 0.3;
            }
        }
    }
    MouseArea {
        id: sectionMouseArea;
        anchors.fill: parent;
        onClicked: internal.click();
    }
}
