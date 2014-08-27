import QtQuick 1.0
import com.nokia.symbian 1.0

ToolButton {
    id: root;

    property string toolTipText;
    opacity: enabled ? 1 : 0.25;
    //platformInverted: tbsettings.whiteTheme;
    onPlatformPressAndHold: {
        toolTip.target = root;
        toolTip.text = toolTipText;
        toolTip.visible = true;
    }
    onPlatformReleased: {
        toolTip.visible = false;
    }
}
