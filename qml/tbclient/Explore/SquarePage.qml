import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"

MyPage {
    id: page;

    title: qsTr("Square")

    tools: ToolBarLayout {
        BackButton {}
    }

    ViewHeader {
        id: viewHeader;
    }
}
