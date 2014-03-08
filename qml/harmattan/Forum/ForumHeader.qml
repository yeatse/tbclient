import QtQuick 1.1
import com.nokia.meego 1.1

Item {
    id: root;

    signal likeButtonClicked;
    signal signButtonClicked;

    width: page.width;
    height: contentCol.height + constant.paddingLarge*3;

    BorderImage {
        id: bgImg;
        anchors.fill: parent;
        border.bottom: 10;
        source: "../gfx/bg_grade_up"+constant.invertedString;
    }

    Image {
        id: icon;
        anchors {
            left: parent.left; top: parent.top;
            margins: constant.paddingLarge;
        }
        width: constant.thumbnailSize;
        height: width;
        asynchronous: true;
        source: internal.forum.avatar||"";
    }
    Column {
        id: contentCol;
        anchors {
            left: icon.right; right: parent.right;
            top: parent.top; margins: constant.paddingLarge;
        }
        Text {
            font: constant.titleFont;
            color: constant.colorLight;
            text: internal.forum.name||"";
        }
        Text {
            font: constant.subTitleFont;
            color: constant.colorMid;
            text: qsTr("<b>%1</b> members, <b>%2</b> posts")
            .arg(internal.forum.member_num).arg(internal.forum.post_num);
            textFormat: Text.StyledText;
        }
        Item { width: 1; height: constant.paddingSmall; }
        Row {
            spacing: constant.paddingXLarge;

            Column {
                visible: internal.isLike;
                anchors.verticalCenter: parent.verticalCenter;

                Text {
                    font: constant.subTitleFont;
                    color: constant.colorMid;
                    text: (internal.forum.level_name)+"  "
                          +qsTr("Lv.%1").arg(internal.forum.level_id);
                }
                ProgressBar {
                    width: parent.width;
                    minimumValue: 0;
                    maximumValue: internal.forum.levelup_score||0;
                    value: internal.forum.cur_score||0;
                }
            }

            Image {
                width: 111
                height: 46
                visible: !internal.isLike;
                anchors.verticalCenter: parent.verticalCenter;
                sourceSize: Qt.size(width, height);
                source: "../gfx/btn_like_"+likeBtnMouseArea.stateString+constant.invertedString;
                MouseArea {
                    id: likeBtnMouseArea;
                    property string stateString: pressed ? "s" : "n";
                    anchors.fill: parent;
                    onClicked: root.likeButtonClicked();
                }
            }

            Image {
                width: 111;
                height: 46;
                visible: !internal.hasSigned;
                anchors.verticalCenter: parent.verticalCenter;
                sourceSize: Qt.size(width, height);
                source: "../gfx/btn_sign_"+signBtnMouseArea.stateString+constant.invertedString;
                BusyIndicator {
                    anchors.centerIn: parent;
                    running: true;
                    visible: internal.signing;
                }
                MouseArea {
                    id: signBtnMouseArea;
                    property string stateString: pressed||internal.signing ? "s" : "n";
                    anchors.fill: parent;
                    enabled: !internal.signing;
                    onClicked: root.signButtonClicked();
                }
            }

            Image {
                width: signInfoText.paintedWidth + 20;
                height: 46;
                visible: internal.hasSigned;
                anchors.verticalCenter: parent.verticalCenter;
                source: "../gfx/ico_sign"+constant.invertedString;
                smooth: true;
                Text {
                    id: signInfoText;
                    anchors.centerIn: parent;
                    font: constant.subTitleFont;
                    color: "red";
                    text: qsTr("Signed %1 days").arg(internal.signDays);
                }
            }
        }
    }
}
