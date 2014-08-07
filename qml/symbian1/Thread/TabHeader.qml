import QtQuick 1.0
import com.nokia.symbian 1.0

Rectangle {
    id: root;

    default property alias content: tabBarLayout.data;
    property alias layout: tabBarLayout;

    width: screen.width;
    height: constant.headerHeight;
    color: "#1080dd";
    z: 10;

    Image {
        anchors { left: parent.left; top: parent.top; }
        source: "../gfx/meegoTLCorner.png";
    }
    Image {
        anchors { right: parent.right; top: parent.top; }
        source: "../gfx/meegoTRCorner.png";
    }

    TabBarLayout { id: tabBarLayout; anchors.fill: parent; }

    Rectangle {
        id: currentSectionIndicator;
        anchors.bottom: parent.bottom;
        color: "white";
        height: constant.paddingSmall;
        width: parent.width;
        Behavior on x { SmoothedAnimation { duration: 200; } }
    }

    QtObject {
        id: internal;

        function resizeIndicatorLength(){
            currentSectionIndicator.width = root.width / Math.max(1, tabBarLayout.children.length);
        }

        function setIndicatorPosition(){
            for (var i=0, l=tabBarLayout.children.length; i<l; i++){
                var btn = tabBarLayout.children[i];
                if (btn.hasOwnProperty("checked") && btn.checked){
                    currentSectionIndicator.x = currentSectionIndicator.width*i;
                    break;
                }
            }
        }
        function setButtonConnections(){
            for (var i=0, l=tabBarLayout.children.length; i<l; i++){
                var btn = tabBarLayout.children[i];
                if (btn.hasOwnProperty("checked")){
                    btn.checkedChanged.disconnect(setIndicatorPosition);
                    btn.checkedChanged.connect(setIndicatorPosition);
                }
            }
        }
    }

    Connections {
        target: tabBarLayout;
        onWidthChanged: {
            internal.resizeIndicatorLength();
            internal.setIndicatorPosition();
        }
        onChildrenChanged: {
            internal.resizeIndicatorLength();
            internal.setIndicatorPosition();
            internal.setButtonConnections();
        }
        Component.onCompleted: {
            internal.resizeIndicatorLength();
            internal.setIndicatorPosition();
            internal.setButtonConnections();
        }
    }
}
