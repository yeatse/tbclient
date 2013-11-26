import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
    id: root;

    signal clicked;

    onClicked: {
        var prop = { forum: forum, tid: model.tid, title: model.title, picAmount: model.amount }
        var p = pageStack.push(Qt.resolvedUrl("../ThreadPicturePage.qml"), prop);
        p.getlist();
    }

    implicitWidth: screen.width / 2;
    implicitHeight: Math.floor(pheight / pwidth * width);

    Image {
        id: image;
        anchors.fill: rect;
        opacity: 0;
        onStatusChanged: {
            if (status == Image.Ready){
                opacity = 1;
            }
        }
        Behavior on opacity { NumberAnimation { duration: 200; } }
    }

    Image {
        anchors.centerIn: parent;
        source: "../../gfx/photos.svg";
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
