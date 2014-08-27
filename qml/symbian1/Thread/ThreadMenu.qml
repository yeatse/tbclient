import QtQuick 1.0
import com.nokia.symbian 1.0

ContextMenu {
    id: root;

    property int index: -1;
    property variant model: null;

    MenuLayout {
        MenuItem {
            property bool isCollected: model != null && model.id === collectMarkPid;
            text: isCollected ? qsTr("Remove from bookmark") : qsTr("Add to bookmark");
            onClicked: isCollected ? rmStore() : addStore(model.id);
        }
        MenuItem {
            text: qsTr("Reader mode");
            onClicked: {
                var prop = { listModel: view.model, currentIndex: index, parentView: view, title: title }
                pageStack.push(Qt.resolvedUrl("ReaderPage.qml"), prop);
            }
        }
        MenuItem {
            text: qsTr("Copy content");
            onClicked: signalCenter.copyToClipboard(model.content_raw);
        }
        MenuItem {
            text: qsTr("Delete this post");
            // is manager || is author || is lz
            visible: model != null && (user.is_manager !== "0"
                                       ||model.authorId === tbsettings.currentUid
                                       ||thread.author.id === tbsettings.currentUid);
            onClicked: delPost(root.index);
        }
        MenuItem {
            text: qsTr("Commit to prison");
            visible: user.is_manager !== "0";
            onClicked: {
                var prop = {
                    fname: forum.name,
                    fid: forum.id,
                    tid: thread.id,
                    username: model.authorName,
                    majorManager: user.is_manager === "1"
                }
                signalCenter.commitPrison(prop);
            }
        }
    }
}
