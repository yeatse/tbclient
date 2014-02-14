import QtQuick 1.1

ToolButtonWithTip {
    toolTipText: qsTr("Back");
    iconSource: "toolbar-back";
    onClicked: pageStack.pop();
}
