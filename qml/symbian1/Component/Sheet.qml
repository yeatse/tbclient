import QtQuick 1.0
import com.nokia.symbian 1.0

Item {
    id: root

    width: parent ? parent.width : 0
    height: parent ? parent.height : 0

    property bool platformInverted: false;
    property color headerBackgroundColor: "#1080dd";
    property int rejectButtonLeftMargin: 15;
    property int acceptButtonRightMargin: 15;

    property alias title: titleBar.children 
    property alias content: contentField.children
    property alias buttons: buttonRow.children
    property Item visualParent
    property int status: DialogStatus.Closed

    property alias acceptButtonText: acceptButton.text
    property alias rejectButtonText: rejectButton.text

    property alias acceptButton: acceptButton
    property alias rejectButton: rejectButton

    signal accepted
    signal rejected

    function reject() {
        close();
        rejected();
    }

    function accept() {
        close();
        accepted();
    }

    visible: status != DialogStatus.Closed;
    
    function open() {
        parent = visualParent || __findParent();
        sheet.state = "";
    }

    function close() {
        sheet.state = "closed";
    }

    function __findParent() {
        var next = parent;
        while (next && next.parent && next.objectName != "window"){
            next = next.parent;
        }
        return next;
    }

    function getButton(name) {
        for (var i=0; i<buttons.length; ++i) {
            if (buttons[i].objectName == name)
                return buttons[i];
        }
        return undefined;
    }

    MouseArea {
        id: blockMouseInput
        anchors.fill: parent
    }
    
    Item {
        id: sheet

        //when the sheet is part of a page do nothing
        //when the sheet is a direct child of a PageStackWindow, consider the status bar
        property int statusBarOffset: (typeof orientationLock != "undefined")
                                      ? 0 : privateStyle.statusBarHeight;
        
        width: parent.width
        height: parent.height - statusBarOffset

        y: statusBarOffset

        clip: true
        
        property int transitionDurationIn: 300
        property int transitionDurationOut: 450
        
        state: "closed"
        
        function transitionStarted() {
            status = (state == "closed") ? DialogStatus.Closing : DialogStatus.Opening;
        }
        
        function transitionEnded() {
            status = (state == "closed") ? DialogStatus.Closed : DialogStatus.Open;
        }
        
        states: [
            // Closed state.
            State {
                name: "closed"
                // consider input panel height when input panel is open
                PropertyChanges { target: sheet; y: inputContext.visible ? inputContext.height + height : height; }
                PropertyChanges { target: sheet; opacity: 0; }
            }
        ]

        transitions: [
            // Transition between open and closed states.
            Transition {
                from: ""; to: "closed"; reversible: false
                SequentialAnimation {
                    ScriptAction { script: if (sheet.state == "closed") { sheet.transitionStarted(); } else { sheet.transitionEnded(); } }
                    ParallelAnimation {
                        NumberAnimation { properties: "y"; easing.type: Easing.InOutQuint; duration: sheet.transitionDurationOut; }
                        NumberAnimation { properties: "opacity"; duration: sheet.transitionDurationOut; }
                    }
                    ScriptAction { script: if (sheet.state == "closed") { sheet.transitionEnded(); } else { sheet.transitionStarted(); } }
                }
            },
            Transition {
                from: "closed"; to: ""; reversible: false
                SequentialAnimation {
                    ScriptAction { script: if (sheet.state == "") { sheet.transitionStarted(); } else { sheet.transitionEnded(); } }
                    ParallelAnimation {
                        NumberAnimation { properties: "y"; easing.type: Easing.OutQuint; duration: sheet.transitionDurationIn; }
                        NumberAnimation { properties: "opacity"; duration: sheet.transitionDurationIn; }
                    }
                    ScriptAction { script: if (sheet.state == "") { sheet.transitionEnded(); } else { sheet.transitionStarted(); } }
                }
            }
        ]
        
        Rectangle {
            width: parent.width
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            color: platformInverted ? platformStyle.colorBackgroundInverted
                                    : platformStyle.colorBackground
            Item {
                id: contentField
                anchors.fill: parent
            }
        }

        Rectangle {
            id: header
            width: parent.width
            height: screen.width < screen.height ? privateStyle.tabBarHeightPortrait
                                                 : privateStyle.tabBarHeightLandscape;
            color: root.headerBackgroundColor;
            Image {
                anchors { left: parent.left; top: parent.top; }
                source: "../gfx/meegoTLCorner.png";
            }
            Image {
                anchors { right: parent.right; top: parent.top; }
                source: "../gfx/meegoTRCorner.png";
            }
            Item {
                id: buttonRow
                anchors.fill: parent
                ToolButton {
                    id: rejectButton
                    objectName: "rejectButton"
                    //platformInverted: root.platformInverted;
                    anchors.left: parent.left
                    anchors.leftMargin: root.rejectButtonLeftMargin;
                    anchors.verticalCenter: parent.verticalCenter
                    visible: text != ""
                    onClicked: close()
                }
                ToolButton {
                    id: acceptButton
                    objectName: "acceptButton"
                    //platformInverted: root.platformInverted;
                    anchors.right: parent.right
                    anchors.rightMargin: root.acceptButtonRightMargin
                    anchors.verticalCenter: parent.verticalCenter
                    visible: text != ""     
                    onClicked: close()
                }
                Component.onCompleted: {
                    acceptButton.clicked.connect(accepted)
                    rejectButton.clicked.connect(rejected)
                }
            }
            Item {
                id: titleBar
                anchors.fill: parent
            }
        }
    }
}
