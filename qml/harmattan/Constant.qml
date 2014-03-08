import QtQuick 1.1
import com.nokia.meego 1.1

QtObject {
    id: constant;

    // color
    property color colorLight: tbsettings.whiteTheme ? "#191919" : "#ffffff";
    property color colorMid: tbsettings.whiteTheme ? "#505050" : "#d2d2d2";
    property color colorMarginLine: tbsettings.whiteTheme ? "#a9a9a9" : "#444444";
    property color colorTextSelection: tbsettings.whiteTheme ? "#4591ff" : "#0072b2";
    property color colorDisabled: tbsettings.whiteTheme ? "#b2b2b4" : "#7f7f7f";

    // padding size
    property int paddingSmall: 4;
    property int paddingMedium: 6;
    property int paddingLarge: 12;
    property int paddingXLarge: 24;

    // graphic size
    property int graphicSizeTiny: 32;
    property int graphicSizeSmall: 48;
    property int graphicSizeMedium: 64;
    property int graphicSizeLarge: 80;
    property int thumbnailSize: 120;

    // font size
    property int fontXSmall: 16;
    property int fontSmall: 22;
    property int fontMedium: 24;
    property int fontLarge: 26;
    property int fontXLarge: 28;
    property int fontXXLarge: 32;
    property variant subTitleFont: __subTitleText.font;
    property variant labelFont: __label.font;
    property variant titleFont: __titleText.font;

    // size
    property variant sizeTiny: Qt.size(graphicSizeTiny, graphicSizeTiny);
    property variant sizeMedium: Qt.size(graphicSizeMedium, graphicSizeMedium);

    // others
    property int headerHeight: app.inPortrait ? 72 : 56;
    property string invertedString: tbsettings.whiteTheme ? ".png" : "_1.png";

    // private
    property Text __titleText: Text {
        font.pixelSize: fontLarge;
        font.family: "Nokia Pure Text";
    }
    property Text __subTitleText: Text {
        font.pixelSize: fontSmall;
        font.family: "Nokia Pure Text";
        font.weight: Font.Light;
    }
    property Text __label: Text {
        font.pixelSize: fontMedium;
        font.family: "Nokia Pure Text";
    }
}
