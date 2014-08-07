import QtQuick 1.0

ToolButtonWithTip {
    toolTipText: qsTr("Back");
    iconSource: "toolbar-back";
    onClicked: pageStack.pop();
}
