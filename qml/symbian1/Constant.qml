import QtQuick 1.0
import com.nokia.symbian 1.0
import "Component"

QtObject {
    id: constant;

    // color
    property color colorLight: platformStyle.colorNormalLight;
    property color colorMid: platformStyle.colorNormalMid;
    property color colorMarginLine: platformStyle.colorDisabledMid;
    property color colorTextSelection: platformStyle.colorTextSelection;
    property color colorDisabled: platformStyle.colorDisabledMid;

    // padding size
    property int paddingSmall: platformStyle.paddingSmall
    property int paddingMedium: platformStyle.paddingMedium
    property int paddingLarge: platformStyle.paddingLarge
    property int paddingXLarge: platformStyle.paddingLarge + platformStyle.paddingSmall

    // graphic size
    property int graphicSizeTiny: platformStyle.graphicSizeTiny
    property int graphicSizeSmall: platformStyle.graphicSizeSmall
    property int graphicSizeMedium: platformStyle.graphicSizeMedium
    property int graphicSizeLarge: platformStyle.graphicSizeLarge
    property int thumbnailSize: platformStyle.graphicSizeLarge * 1.5

    // font size
    property int fontXSmall: platformStyle.fontSizeSmall - 2
    property int fontSmall: platformStyle.fontSizeSmall
    property int fontMedium: platformStyle.fontSizeMedium
    property int fontLarge: platformStyle.fontSizeLarge
    property int fontXLarge: platformStyle.fontSizeLarge + 2
    property int fontXXLarge: platformStyle.fontSizeLarge + 4
    property variant subTitleFont: __subTitleText.font;
    property variant labelFont: __label.font;
    property variant titleFont: __titleText.font;

    // size
    property variant sizeTiny: Qt.size(graphicSizeTiny, graphicSizeTiny);
    property variant sizeMedium: Qt.size(graphicSizeMedium, graphicSizeMedium);

    // others
    property int headerHeight: app.inPortrait ? privateStyle.tabBarHeightPortrait
                                              : privateStyle.tabBarHeightLandscape;
    //property string invertedString: tbsettings.whiteTheme ? "_inverted" : "";

    // private
    property ListItemText __titleText: ListItemText {}
    property ListItemText __subTitleText: ListItemText { role: "SubTitle"; }
    property Label __label: Label {}
}
