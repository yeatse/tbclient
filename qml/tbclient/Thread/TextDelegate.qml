import QtQuick 1.1

Text {
    text: model.text;
    textFormat: format;
    width: parent.width;
    wrapMode: Text.WrapAnywhere;
    font: constant.labelFont;
    color: constant.colorLight;
    onLinkActivated: console.log(link);
}
