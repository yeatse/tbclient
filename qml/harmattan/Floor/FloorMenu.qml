import QtQuick 1.1
import com.nokia.meego 1.1
import "../Component"

AbstractDialog {
    id: root;

    property int index: -1;
    property variant model: null;

    contentList: [
        DialogItem {
            text: qsTr("Copy content");
            onClicked: signalCenter.copyToClipboard(model.content);
        },
        DialogItem {
            text: qsTr("Delete this post");
            visible: model != null && (managerGroup !== 0
                                       ||model.authorId === tbsettings.currentUid
                                       ||internal.thread.author.id === tbsettings.currentUid);
            onClicked: internal.delPost(root.index);
        },
        DialogItem {
            text: qsTr("Commit to prison");
            visible: managerGroup !== 0;
            onClicked: {
                var prop = {
                    fname: internal.forum.name,
                    fid: internal.forum.id,
                    tid: internal.thread.id,
                    username: model.author,
                    majorManager: managerGroup === 1
                }
                signalCenter.commitPrison(prop);
            }
        }
    ]
}
