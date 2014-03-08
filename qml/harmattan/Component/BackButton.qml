import QtQuick 1.1
import com.nokia.meego 1.1

ToolIcon {
    platformIconId: "toolbar-back";
    onClicked: pageStack.pop();
}
