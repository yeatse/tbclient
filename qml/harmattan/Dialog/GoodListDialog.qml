import QtQuick 1.1
import com.nokia.meego 1.1

SelectionDialog {
    id: root;

    signal goodSelected(string cid);

    property bool __isClosing: false;

    titleText: qsTr("Select class");
    model: ListModel {}

    onAccepted: goodSelected(model.get(selectedIndex).id);

    onStatusChanged: {
        if (status === DialogStatus.Closing){
            __isClosing = true;
        } else if (status === DialogStatus.Closed && __isClosing){
            root.destroy(250);
        }
    }
}
