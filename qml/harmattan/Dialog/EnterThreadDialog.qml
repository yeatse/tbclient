import QtQuick 1.1
import com.nokia.meego 1.1
import "../Component"

AbstractDialog {
    id: root;

    property bool __isClosing: false;

    property string title;
    property bool isfloor;
    property string pid;
    property string tid;
    property string fname;
    property bool fromSearch: false;

    titleText: title;

    contentList: [
        DialogItem {
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
        },
        DialogItem {
            text: qsTr("View this thread");
            onClicked: {
                var prop = { title: title, threadId: tid };
                signalCenter.enterThread(prop);
            }
        },
        DialogItem {
            text: qsTr("View this forum");
            onClicked: signalCenter.enterForum(fname);
        }
    ]
    onStatusChanged: {
        if (status == DialogStatus.Closing){
            __isClosing = true;
        } else if (status == DialogStatus.Closed && __isClosing){
            root.destroy(250);
        }
    }
    Component.onCompleted: open();
}
