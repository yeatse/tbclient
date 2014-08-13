import QtQuick 1.0
import com.nokia.symbian 1.0

Item {
    id: root;

    signal likeButtonClicked;
    signal signButtonClicked;

    width: screen.width;
    height: constant.thumbnailSize;

    BorderImage {
        id: bgImg;
        asynchronous: true;
        anchors.fill: parent;
        source: privateStyle.imagePath("qtg_fr_list_heading_normal");
        border { left: 28; top: 5; right: 28; bottom: 0 }
        smooth: true;
    }

    Image {
        id: icon;
        anchors {
            left: parent.left; top: parent.top;
            bottom: parent.bottom; margins: constant.paddingLarge;
        }
        asynchronous: true;
        width: height;
        source: internal.forum.avatar||"";
    }
    Column {
        anchors {
            left: icon.right;
            leftMargin: constant.paddingLarge;
            verticalCenter: parent.verticalCenter;
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
            spacing: constant.paddingLarge;
            Column {
                visible: internal.isLike;
                anchors.verticalCenter: parent.verticalCenter;
                Text {
                    font.pixelSize: constant.fontXSmall;
                    font.weight: Font.Light;
                    color: constant.colorMid;
                    text: (internal.forum.level_name)+"  "
                          +qsTr("Lv.%1").arg(internal.forum.level_id);
                }
                ProgressBar {
                    width: constant.thumbnailSize;
                    //platformInverted: tbsettings.whiteTheme;
                    minimumValue: 0;
                    maximumValue: internal.forum.levelup_score||0;
                    value: internal.forum.cur_score||0;
                }
            }
            Image {
                width: constant.thumbnailSize; height: Math.floor(width/111*46);
                visible: !internal.isLike;
                anchors.verticalCenter: parent.verticalCenter;
                sourceSize: Qt.size(width, height);
                source: "../gfx/btn_like_"+likeBtnMouseArea.stateString+".png";
                MouseArea {
                    id: likeBtnMouseArea;
                    property string stateString: pressed ? "s" : "n";
                    anchors.fill: parent;
                    onClicked: root.likeButtonClicked();
                }
            }
            Image {
                width: constant.thumbnailSize; height: Math.floor(width/111*46);
                visible: !internal.hasSigned;
                anchors.verticalCenter: parent.verticalCenter;
                sourceSize: Qt.size(width, height);
                source: "../gfx/btn_sign_"+signBtnMouseArea.stateString+".png";
                BusyIndicator {
                    anchors.centerIn: parent;
                    //platformInverted: tbsettings.whiteTheme;
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
                width: Math.max(constant.thumbnailSize, signInfoText.width+constant.paddingLarge*2);
                height: Math.floor(constant.thumbnailSize/111*46);
                visible: internal.hasSigned;
                anchors.verticalCenter: parent.verticalCenter;
                source: "../gfx/ico_sign.png";
                smooth: true;
                Text {
                    id: signInfoText;
                    anchors.centerIn: parent;
                    font: constant.subTitleFont;
                    color: "darkred";
                    text: qsTr("Signed %1 days").arg(internal.signDays);
                }
            }
        }
    }
}
