import QtQuick 1.0
import com.nokia.symbian 1.0

Item {
    id: root;

    signal clicked;

    onClicked: {
        var prop = { title: title, forumName: internal.forum.name, threadId: tid };
        pageStack.push(Qt.resolvedUrl("../Thread/ThreadPicture.qml"), prop);
    }

    width: screen.width / 2;
    height: Math.floor(pheight / pwidth * width);

    Image {
        id: image;
        anchors.fill: rect;
        opacity: 0;
        asynchronous: true;
        onStatusChanged: {
            if (status == Image.Ready){
                opacity = 1;
            }
        }
        Behavior on opacity { NumberAnimation { duration: 200; } }
    }

    Image {
        anchors.centerIn: parent;
        asynchronous: true;
        source: "../gfx/photos.svg";
        visible: image.status != Image.Ready;
    }

    Rectangle {
        id: rect;
        anchors { fill: parent; margins: constant.paddingMedium; }
        color: "#00000000";
        border {
            width: 1;
            color: constant.colorMarginLine;
        }
        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom; }
            height: Math.min(parent.height/2, constant.graphicSizeSmall);
            color: "#C0000000";
            ListItemText {
                anchors { left: parent.left; right: parent.right; }
                anchors.verticalCenter: parent.verticalCenter;
                text: title;
                role: "SubTitle";
            }
        }
    }

    MouseArea {
        id: mouseArea;
        anchors.fill: parent;
        onPressed: root.opacity = 0.7;
        onReleased: root.opacity = 1;
        onCanceled: root.opacity = 1;
        onClicked: root.clicked();
    }

    function setSource(){
        var tly = root.mapToItem(view, 0, 0).y;
        if (tly >= -root.height && tly <= view.height){
            setSourceConnections.target = null;
            image.source = cover;
        }
    }

    Connections {
        id: setSourceConnections;
        target: view;
        onMovementEnded: setSource();
    }

    Connections {
        id: signalCenterConnections;
        target: view;
        onFinished: {
            signalCenterConnections.target = null;
            setSource();
        }
    }
}
