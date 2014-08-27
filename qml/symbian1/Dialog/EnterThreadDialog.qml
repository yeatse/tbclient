import QtQuick 1.0
import com.nokia.symbian 1.0

ContextMenu {
    id: root;

    property bool __isClosing: false;

    property string title;
    property bool isfloor;
    property string pid;
    property string tid;
    property string fname;
    property bool fromSearch: false;

    MenuLayout {
        MenuItem {
            text: qsTr("View this post");
            onClicked: {
                if (isfloor){
                    if (fromSearch) signalCenter.enterFloor(tid, pid);
                    else signalCenter.enterFloor(tid, undefined, pid);
                }
                else {
                    var prop = { title: title, threadId: tid, pid: pid };
                    signalCenter.enterThread(prop);
                }
            }
        }
        MenuItem {
            text: qsTr("View this thread");
            onClicked: {
                var prop = { title: title, threadId: tid };
                signalCenter.enterThread(prop);
            }
        }
        MenuItem {
            text: qsTr("View this forum");
            onClicked: signalCenter.enterForum(fname);
        }
    }
    onStatusChanged: {
        if (status == DialogStatus.Closing){
            __isClosing = true;
        } else if (status == DialogStatus.Closed && __isClosing){
            root.destroy();
        }
    }
    Component.onCompleted: open();
}
