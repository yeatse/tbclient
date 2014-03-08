import QtQuick 1.1
import com.nokia.meego 1.1
import "Component"

MyPage {
    id: page;

    title: qsTr("About tbclient");

    tools: ToolBarLayout {
        BackButton {}
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
    }

    Column {
        anchors {
            horizontalCenter: parent.horizontalCenter;
            top: viewHeader.bottom;
            topMargin: app.inPortrait ? constant.graphicSizeLarge : constant.paddingLarge;
        }
        spacing: constant.paddingMedium;

        Image {
            anchors.horizontalCenter: parent.horizontalCenter;
            source: "file:///usr/share/icons/hicolor/80x80/apps/tbclient80.png";
        }

        Text {
            font.pixelSize: constant.fontXXLarge;
            font.family: "Nokia Pure Text";
            color: constant.colorLight;
            anchors.horizontalCenter: parent.horizontalCenter;
            text: qsTr("QML Tieba Client");
        }

        Text {
            font: constant.labelFont;
            color: constant.colorMid;
            anchors.horizontalCenter: parent.horizontalCenter;
            text: "Designed for Meego Harmattan";
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
            text: "Yeatse CC, 2014";
        }
    }
}
