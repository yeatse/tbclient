import QtQuick 1.1
import com.nokia.meego 1.1

Item {
    id: root;

    width: page.width;
    height: contentCol.height + constant.paddingMedium*3;

    Column {
        id: contentCol;
        anchors {
            left: parent.left; leftMargin: constant.paddingLarge;
            right: parent.right; rightMargin: constant.paddingLarge;
            top: parent.top; topMargin: constant.paddingMedium;
        }
        spacing: constant.paddingSmall;
        Text {
            width: parent.width;
            elide: Text.ElideRight;
            wrapMode: Text.WrapAnywhere;
            maximumLineCount: 2;
            textFormat: Text.PlainText;
            font: constant.labelFont;
            color: constant.colorLight;
            text: thread ? thread.title : "";
        }
        Item {
            width: parent.width;
            height: forumBtn.height;
            SheetButton {
                id: forumBtn;
                text: forum ? forum.name + qsTr("Bar") : "";
                onClicked: signalCenter.enterForum(forum.name);
            }
            Loader {
                anchors {
                    right: collectBtn.left; rightMargin: constant.paddingSmall;
                    verticalCenter: parent.verticalCenter;
                }
                sourceComponent: thread && thread.topic && thread.topic.link ? livePostBtn : undefined;
                Component {
                    id: livePostBtn;
                    Image {
                        source: "../gfx/icon_live"+constant.invertedString;
                        opacity: livePostMouseArea.pressed ? 0.6 : 1;
                        MouseArea {
                            id: livePostMouseArea;
                            anchors.fill: parent;
                            onClicked: signalCenter.openBrowser(thread.topic.link);
                        }
                    }
                }
            }
            Image {
                id: collectBtn;
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; }
                source: "../gfx/icon_grade_middle_star_%1.png".arg(collectMouseArea.pressed||isCollected?"s":"n");
                MouseArea {
                    id: collectMouseArea;
                    enabled: !loading;
                    anchors.fill: parent;
                    onClicked: isCollected ? rmStore() : addStore();
                }
            }
        }
    }

    Rectangle {
        anchors {
            left: root.left; right: parent.right; bottom: parent.bottom;
        }
        height: 1;
        color: constant.colorMarginLine;
    }
}
