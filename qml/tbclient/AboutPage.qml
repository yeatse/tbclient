import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"

MyPage {
    id: page;

    title: qsTr("About tbclient");

    tools: ToolBarLayout {
        BackButton {}
    }

    // For keypad
    onStatusChanged: {
        if (status === PageStatus.Active){
            page.forceActiveFocus();
        }
    }
}
