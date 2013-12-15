import QtQuick 1.1

Text {
    text: model.text;
    textFormat: format;
    width: parent.width;
    wrapMode: Text.WrapAnywhere;
    font.pixelSize: tbsettings.fontSize;
    font.family: platformStyle.fontFamilyRegular;
    color: constant.colorLight;
    onLinkActivated: signalCenter.linkClicked(link);
}
