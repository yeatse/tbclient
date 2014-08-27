import QtQuick 1.0
import com.nokia.symbian 1.0

Row {
    id: root;

    property string text;

    opacity: app.showStatusBar ? 1 : 0;
    anchors { left: parent.left; top: parent.top; }

    // Busy indicator.
    BusyIndicator {
        id: busyIndicator;
        width: privateStyle.statusBarHeight;
        height: privateStyle.statusBarHeight;
        running: true;
        visible: infoCenter.loading||pageStack.currentPage.loading||false;
    }

    // To scroll the text.
    Flickable {
        id: scrollingTitle;
        clip: true;
        interactive: false;
        height: privateStyle.statusBarHeight;
        width: screen.width - 200;

        contentWidth: Math.max(statusPaneTitle.width, width);
        contentHeight: privateStyle.statusBarHeight;

        onWidthChanged: resetAnimation();

        function resetAnimation(){
            scrollingAnimation.complete();
            if (statusPaneTitle.width > scrollingTitle.width){
                scrolling.to = statusPaneTitle.width - scrollingTitle.width;
                scrollingAnimation.start();
            }
        }

        Label {
            id: statusPaneTitle;
            height: parent.height;
            verticalAlignment: Text.AlignVCenter;
            font.pixelSize: platformStyle.fontSizeSmall;
            textFormat: Text.PlainText;
            onTextChanged: scrollingTitle.resetAnimation();
            text: root.text;
        }

        SequentialAnimation {
            id: scrollingAnimation;
            PropertyAction { target: scrollingTitle; property: "contentX"; value: 0; }
            PauseAnimation { duration: 1000; }
            PropertyAnimation {
                id: scrolling;
                target: scrollingTitle;
                property: "contentX";
                duration: to*30;
            }
            PauseAnimation { duration: 1000; }
            PropertyAnimation { target: scrollingTitle; property: "contentX"; to: 0; }
        }
    }
}
