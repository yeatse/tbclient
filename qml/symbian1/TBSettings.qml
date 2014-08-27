import QtQuick 1.0

QtObject {
    id: tbsettings;

    // system
    property string currentUid: utility.getValue("currentUid", "");
    onCurrentUidChanged: utility.setValue("currentUid", currentUid);

    property int clientType: utility.getValue("clientType", 1);
    onClientTypeChanged: utility.setValue("clientType", clientType);

    property string clientId: utility.getValue("clientId", "0");
    onClientIdChanged: utility.setValue("clientId", clientId);

    property string imagePath: utility.getValue("imagePath", utility.defaultPictureLocation);
    onImagePathChanged: utility.setValue("imagePath", imagePath);

    property string browser: utility.getValue("browser", "System");
    onBrowserChanged: utility.setValue("browser", browser);

    property string signature: utility.getValue("signature", "");
    onSignatureChanged: utility.setValue("signature", signature);

    property bool monitorNetworkMode: utility.getValue("monitorNetworkMode", false);
    onMonitorNetworkModeChanged: utility.setValue("monitorNetworkMode", monitorNetworkMode);

    property string draftBox: utility.getValue("draftBox", "");
    onDraftBoxChanged: utility.setValue("draftBox", draftBox);

    property int volumeLevel: utility.getValue("volumeLevel", 7);
    onVolumeLevelChanged: utility.setValue("volumeLevel", volumeLevel);

    property string currentBearerName;
    onCurrentBearerNameChanged: {
        console.log("currnet bearer:", currentBearerName);
        if (!monitorNetworkMode) return;
        switch (currentBearerName){
        case "2G": {
            signalCenter.showMessage(qsTr("Mobile network used"));
            remindInterval = remindInterval == 0 ? 0 : Math.max(remindInterval, 5);
            remindBackground = false;
            showImage = false;
            break;
        }
        case "CDMA2000":
        case "WCDMA":
        case "HSPA":
        case "WLAN": {
            signalCenter.showMessage(qsTr("High speed network used"));
            remindInterval = remindInterval == 0 ? 0 : Math.min(remindInterval, 1);
            remindBackground = true;
            showImage = true;
            break;
        }
        }
    }

    // design
    property bool whiteTheme: false;

    property bool showImage: utility.getValue("showImage", true);
    onShowImageChanged: utility.setValue("showImage", showImage);

    property bool showAbstract: utility.getValue("showAbstract", true);
    onShowAbstractChanged: utility.setValue("showAbstract", showAbstract);

    property int maxTabCount: utility.getValue("maxTabCount", 4);
    onMaxTabCountChanged: utility.setValue("maxTabCount", maxTabCount);

    property int fontSize: utility.getValue("fontSize", constant.fontMedium);
    onFontSizeChanged: utility.setValue("fontSize", fontSize);

    property string bgImageUrl: utility.getValue("bgImageUrl", "");
    onBgImageUrlChanged: utility.setValue("bgImageUrl", bgImageUrl);

    // remind
    property int remindInterval: utility.getValue("remind/interval", 5);
    onRemindIntervalChanged: utility.setValue("remind/interval", remindInterval);

    property bool remindBackground: utility.getValue("remind/background", true);
    onRemindBackgroundChanged: utility.setValue("remind/background", remindBackground);

    property bool remindFans: utility.getValue("remind/fans", true);
    onRemindFansChanged: utility.setValue("remind/fans", remindFans);

    property bool remindPletter: utility.getValue("remind/pletter", true);
    onRemindPletterChanged: utility.setValue("remind/pletter", remindPletter);

    property bool remindBookmark: utility.getValue("remind/bookmark", false);
    onRemindBookmarkChanged: utility.setValue("remind/bookmark", remindBookmark);

    property bool remindReplyme: utility.getValue("remind/replyme", true);
    onRemindReplymeChanged: utility.setValue("remind/replyme", remindReplyme);

    property bool remindAtme: utility.getValue("remind/atme", true);
    onRemindAtmeChanged: utility.setValue("remind/atme", remindAtme);
}
