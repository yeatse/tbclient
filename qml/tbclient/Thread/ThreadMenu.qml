import QtQuick 1.1
import com.nokia.symbian 1.1

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
        }
        MenuItem {
            text: qsTr("Commit to prison");
        }
    }
}
