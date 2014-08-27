import QtQuick 1.0
import com.nokia.symbian 1.0
import "Component"

MyPage {
    id: page;

    title: qsTr("About tbclient");

    tools: ToolBarLayout {
        BackButton {}
    }

    Column {
        anchors {
            horizontalCenter: parent.horizontalCenter;
            top: parent.top;
            topMargin: app.inPortrait ? constant.graphicSizeLarge : 0;
        }
        spacing: constant.paddingMedium;

        Image {
            anchors.horizontalCenter: parent.horizontalCenter;
            sourceSize.width: constant.graphicSizeLarge*2.5;
            sourceSize.height: constant.graphicSizeLarge*2.5;
            source: "gfx/tbclient.svg";
        }

        Text {
            font.pixelSize: constant.fontXXLarge;
            font.family: platformStyle.fontFamilyRegular;
            color: constant.colorLight;
            anchors.horizontalCenter: parent.horizontalCenter;
            text: qsTr("QML Tieba Client");
        }

        Text {
            font: constant.labelFont;
            color: constant.colorMid;
            anchors.horizontalCenter: parent.horizontalCenter;
            text: "Designed for Nokia S60V5";
        }

        Text {
            font: constant.subTitleFont;
            color: constant.colorMid;
            anchors.horizontalCenter: parent.horizontalCenter;
            text: "Version "+utility.appVersion;
        }
    }

    Column {
        anchors {
            horizontalCenter: parent.horizontalCenter;
            bottom: parent.bottom; bottomMargin: constant.paddingMedium;
        }
        visible: screen.height > 360;
        Text {
            font: constant.subTitleFont;
            color: constant.colorMid;
            anchors.horizontalCenter: parent.horizontalCenter;
            text: "<a href=\"w\">%1</a>".arg(qsTr("Project homepage"));
            onLinkActivated: utility.openURLDefault("https://github.com/yeatse/tbclient");
        }
        Text {
            font: constant.subTitleFont;
            color: constant.colorMid;
            anchors.horizontalCenter: parent.horizontalCenter;
            text: "Yeatse CC & Perqin, 2014";
        }
    }

    // For keypad
    onStatusChanged: {
        if (status === PageStatus.Active){
            page.forceActiveFocus();
        }
    }
}
