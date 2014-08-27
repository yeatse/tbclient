#include "utility.h"
#include "tbnetworkaccessmanagerfactory.h"

#include <QSystemDeviceInfo>
#include <QtNetwork>

#ifdef Q_OS_SYMBIAN
#ifdef Q_OS_S60V5
#include <aknglobalnote.h>
#else
#include <akndiscreetpopup.h>       //for discreet popup
#endif
#include <avkon.hrh>                //..
#include <apgcli.h>                 //for launch apps
#include <apgtask.h>                //..
#include <w32std.h>                 //..
#include <mgfetch.h>                //for selecting picture
#include <NewFileServiceClient.h>   //for camera
#include <AiwServiceHandler.h>      //..
#include <AiwCommon.hrh>            //..
#include <AiwGenericParam.hrh>      //..
#endif

#ifdef Q_OS_HARMATTAN
#define CAMERA_SERVICE "com.nokia.maemo.CameraService"
#define CAMERA_INTERFACE "com.nokia.maemo.meegotouch.CameraInterface"
#define NOTIFICATION_EVENTTYPE "tbclient"

#include "videosuiteinterface.h"
#include <MNotification>
#include <MRemoteAction>
#endif

Utility::Utility(QObject *parent) :
    QObject(parent)
{
    settings = new QSettings(this);
}

Utility::~Utility()
{
    settings->deleteLater();
}

Utility* Utility::Instance()
{
    static Utility u;
    return &u;
}

QString Utility::appVersion() const
{
    return qApp->applicationVersion();
}

int Utility::qtVersion() const
{
    QString qtver(qVersion());
    QStringList vlist = qtver.split(".");
    if (vlist.length() >= 3){
        int major = vlist.at(0).toInt();
        int minor = vlist.at(1).toInt();
        int patch = vlist.at(2).toInt();
        return (major << 16) + (minor << 8) + patch;
    } else {
        return 0;
    }
}

QString Utility::imei() const
{
    QtMobility::QSystemDeviceInfo devInfo;
    QString mImei = devInfo.imei();
    mImei = mImei.replace("-", "");
    return mImei;
}

QString Utility::cachePath() const
{
    QString path = QDesktopServices::storageLocation(QDesktopServices::CacheLocation);
    QDir dir(path);
    if (!dir.exists()) dir.mkpath(dir.absolutePath());
    return path;
}

QString Utility::tempPath() const
{
    QString path = QDir::tempPath();
    QDir dir(path);
    if (!dir.exists()) dir.mkpath(path);
    return path;
}

QString Utility::defaultPictureLocation() const
{
    return QDesktopServices::storageLocation(QDesktopServices::PicturesLocation);
}

void Utility::setEngine(QDeclarativeEngine *engine)
{
    this->engine = engine;
}

QVariant Utility::getValue(const QString &key, const QVariant defaultValue)
{
    if (map.contains(key)){
        return map.value(key);
    } else {
        return settings->value(key, defaultValue);
    }
}

void Utility::setValue(const QString &key, const QVariant &value)
{
    if (map.value(key) != value){
        map.insert(key, value);
        settings->setValue(key, value);
    }
}

void Utility::clearSettings()
{
    map.clear();
    settings->clear();
}

void Utility::setUserData(const QString &key, const QString &data)
{
    QString path = QDesktopServices::storageLocation(QDesktopServices::DataLocation) + QDir::separator() + ".userdata";
    QDir dir(path);
    if (!dir.exists()) dir.mkpath(path);

    QString filename = path + QDir::separator() + key + ".dat";
    QFile file(filename);
    if (file.open(QIODevice::WriteOnly)){
        QTextStream stream(&file);
        stream << data;
        file.close();
    }
}

QString Utility::getUserData(const QString &key)
{
    QString path = QDesktopServices::storageLocation(QDesktopServices::DataLocation) + QDir::separator() + ".userdata";
    QString filename = path + QDir::separator() + key + ".dat";
    QString res;
    QFile file(filename);
    if (file.exists() && file.open(QIODevice::ReadOnly)){
        QTextStream stream(&file);
        res = stream.readAll();
        file.close();
    }
    return res;
}

bool Utility::clearUserData()
{
    QString path = QDesktopServices::storageLocation(QDesktopServices::DataLocation) + QDir::separator() + ".userdata";
    return deleteDir(path);
}

void Utility::clearCookies() const
{
    TBNetworkCookieJar::GetInstance()->clearCookies();
}

bool Utility::saveCache(const QString &remoteUrl, const QString &localPath)
{
    if (engine.isNull()) return false;
    QAbstractNetworkCache* diskCache = engine->networkAccessManager()->cache();
    if (diskCache == 0) return false;
    QIODevice* data = diskCache->data(QUrl(remoteUrl));
    if (data == 0) return false;
    QString path = QFileInfo(localPath).absolutePath();
    QDir dir(path);
    if (!dir.exists()) dir.mkpath(path);
    QFile file(localPath);
    if (file.open(QIODevice::WriteOnly)){
        file.write(data->readAll());
        file.close();
        data->deleteLater();
        return true;
    }
	data->deleteLater();
    return false;
}

int Utility::cacheSize()
{
    if (engine.isNull()) return 0;
    QAbstractNetworkCache* diskCache = engine->networkAccessManager()->cache();
    if (diskCache == 0) return 0;
    return diskCache->cacheSize();
}

void Utility::clearCache()
{
    QString cachePath = this->cachePath() + QDir::separator() + "audio";
    this->deleteDir(cachePath);

    if (engine.isNull()) return;
    QAbstractNetworkCache* diskCache = engine->networkAccessManager()->cache();
    if (diskCache == 0) return;
    diskCache->clear();
}

QString Utility::currentBearerName()
{
    return engine->networkAccessManager()->activeConfiguration().bearerTypeName();
}

void Utility::openURLDefault(const QString &url)
{
#ifdef Q_OS_SYMBIAN
    QString browser = this->getValue("browser", "").toString();
    if (browser == "UC"){
        TRAP_IGNORE(LaunchL(0x2001F848, url));
    } else if (browser == "UC International"){
        TRAP_IGNORE(LaunchL(0x2002C577, url));
    } else if (browser == "Opera"){
        TRAP_IGNORE(LaunchL(0x2002AA96, url));
    } else {
        QByteArray ba = QUrl(url).toEncoded();
        TRAP_IGNORE(LaunchL(0x10008D39, "4 "+ba));
    }
#elif defined(Q_WS_SIMULATOR)
    qDebug() << "Open browser:" << url;
#else
    QDesktopServices::openUrl(QUrl(url));
#endif
}

void Utility::launchPlayer(const QString &url)
{
#ifdef Q_OS_SYMBIAN
    QString ramPath = tempPath() + QDir::separator() + "video.ram";
    QFile file(ramPath);
    if (file.exists())
        file.remove();
    if (file.open(QIODevice::ReadWrite)){
        QTextStream out(&file);
        out << url;
        file.close();
        QDesktopServices::openUrl(QUrl("file:///"+ramPath));
    }
#elif defined(Q_OS_HARMATTAN)
    VideoSuiteInterface suite;
    QStringList list = url.split("\n");
    suite.play(list);
#else
    qDebug() << "open player:" << url;
#endif
}

QString Utility::selectImage(int param)
{
#ifdef Q_OS_SYMBIAN
    QString result;
    switch (param){
    case 0:
        TRAP_IGNORE(result = LaunchLibrary());
        break;
    case 1:
        result = QFileDialog::getOpenFileName(0, QString(), QString(), "Images (*.png *.gif *.jpg)");
        break;
    case 2:
        TRAP_IGNORE(result = CaptureImage());
        break;
    case 3:
        TRAP_IGNORE(result = LaunchLibrary2());
    default:
        break;
    }
    return result;
#elif defined(Q_OS_HARMATTAN)
    if (param == 2){
        startCamera();
        return QString();
    } else {
        return QString();
    }
#else
    Q_UNUSED(param);
    return QFileDialog::getOpenFileName(0, QString(), QString(), "Images (*.png *.gif *.jpg)");
#endif
}

QString Utility::selectFolder()
{
    return QFileDialog::getExistingDirectory();
}

QColor Utility::selectColor(const QColor &defaultColor)
{
    QColor result = QColorDialog::getColor();
    if (result.isValid()){
        return result;
    } else {
        return defaultColor;
    }
}

void Utility::showNotification(const QString &title, const QString &message)
{
#ifdef Q_OS_S60V5
    QtMobility::QSystemDeviceInfo deviceInfo;
    bool silent = deviceInfo.currentProfile() != QtMobility::QSystemDeviceInfo::NormalProfile
            && deviceInfo.currentProfile() != QtMobility::QSystemDeviceInfo::LoudProfile;
    TPtrC16 sMessage(static_cast<const TUint16 *>(message.utf16()), message.length());
    CAknGlobalNote* note = CAknGlobalNote::NewLC();
    if (silent){
        note->SetTone(0);
    } else {
        note->SetTone(EAvkonSIDReadialCompleteTone);
    }
    note->ShowNoteL(EAknGlobalInformationNote, sMessage);
    CleanupStack::PopAndDestroy(note);
#elif defined(Q_OS_SYMBIAN)
    TPtrC16 sTitle(static_cast<const TUint16 *>(title.utf16()), title.length());
    TPtrC16 sMessage(static_cast<const TUint16 *>(message.utf16()), message.length());
    TUid uid = TUid::Uid(0x2006622A);
    TRAP_IGNORE(CAknDiscreetPopup::ShowGlobalPopupL(sTitle, sMessage, KAknsIIDNone, KNullDesC, 0, 0, KAknDiscreetPopupDurationLong, 0, NULL, uid));
#elif defined(Q_OS_HARMATTAN)
    clearNotifications();
    MNotification notification(NOTIFICATION_EVENTTYPE, title, message);
    MRemoteAction action("com.tbclient", "/com/tbclient", "com.tbclient", "activateWindow");
    notification.setAction(action);
    notification.publish();
#else
    qDebug() << "showNotification:" << title << message;
#endif
}

void Utility::clearNotifications()
{
#ifdef Q_OS_HARMATTAN
    QList<MNotification*> activeNotifications = MNotification::notifications();
    QMutableListIterator<MNotification*> i(activeNotifications);
    while (i.hasNext()) {
        MNotification *notification = i.next();
        if (notification->eventType() == NOTIFICATION_EVENTTYPE)
            notification->remove();
    }
#endif
}

bool Utility::existsFile(const QString &filename)
{
    return QFile::exists(filename);
}

int Utility::fileSize(const QString &filename)
{
    QFileInfo info(filename);
    return info.size();
}

QString Utility::fileHash(const QString &filename)
{
    QFile file(filename);
    QString result;
    if (file.open(QIODevice::ReadOnly)){
        QByteArray content = file.readAll();
        QByteArray md5 = QCryptographicHash::hash(content, QCryptographicHash::Md5);
        result = QString(md5.toHex());
        file.close();
    }
    return result;
}

QString Utility::chunkFile(const QString &filename, int pos, int length)
{
    QFile file(filename);
    QString result;
    if (file.open(QIODevice::ReadOnly)){
        QFile output(filename+"_chunk_"+QString::number(pos));
        if (output.open(QIODevice::WriteOnly)){
            if (file.seek(pos)){
                QByteArray chunked = file.read(length);
                output.write(chunked);
                result = output.fileName();
            }
            output.close();
        }
        file.close();
    }
    return result;
}

void Utility::copyToClipbord(const QString &text)
{
    qApp->clipboard()->setText(text);
}

QString Utility::cutImage(const QString &filename, double scale, int x, int y, int width, int height)
{
    QImageReader reader(filename);
    if (!reader.canRead() || !reader.supportsOption(QImageIOHandler::Size))
        return QString();

    int scaledWidth = reader.size().width();
    int scaledHeight = reader.size().height();
    // sourceSize.height: 1000
    if (scaledHeight > 1000){
        scaledWidth = scaledWidth * 1000/scaledHeight;
        scaledHeight = 1000;
    }
    scaledWidth *= scale;
    scaledHeight *= scale;
    reader.setScaledSize(QSize(scaledWidth, scaledHeight));
    reader.setScaledClipRect(QRect(x, y, width, height));
    QImage image = reader.read();
    QString result = tempPath().append(QDir::separator()).append("avatar_temp.jpg");
    if (!image.isNull() && image.save(result))
        return result;

    return QString();
}

QString Utility::resizeImage(const QString &filename)
{
    QImage image(filename);
    if (image.isNull())
        return QString();
    if (image.width() > 1600){
        image = image.scaledToWidth(1600);
    } else if (image.height() > 1600){
        image = image.scaledToHeight(1600);
    }
    QString result = tempPath() + QDir::separator() + "upload_temp.jpg";
    if (image.save(result)){
        return result;
    } else {
        return QString();
    }
}

QString Utility::easyDate(const QDateTime &date)
{
    if (formats.length() == 0) initializeLangFormats();

    QDateTime now = QDateTime::currentDateTime();
    int secsDiff = date.secsTo(now);

    QString token;
    if (secsDiff < 0){
        secsDiff = abs(secsDiff);
        token = lang["from"];
    } else {
        token = lang["ago"];
    }

    QString result;
    foreach (QVariantList format, formats) {
        if (secsDiff < format.at(0).toInt()){
            if (format == formats.at(0)){
                result = format.at(1).toString();
            } else {
                int val = ceil(double(normalize(secsDiff, format.at(3).toInt()))/format.at(3).toInt());
                result = tr("%1 %2 %3", "e.g. %1 is number value such as 2, %2 is mins, %3 is ago")
                        .arg(QString::number(val)).arg(val != 1 ? format.at(2).toString() : format.at(1).toString()).arg(token);
            }
            break;
        }
    }
    return result;
}

QString Utility::decodeGBKHex(const QString &encodedString)
{
#ifdef QT_DEBUG
    qDebug() << encodedString;
#endif
    QTextCodec* codec = QTextCodec::codecForName("GBK");
    QByteArray text = QByteArray::fromHex(encodedString.toAscii());
    return codec->toUnicode(text);
}

QString Utility::percentDecode(const QString &encodedString) const
{
    return QUrl::fromPercentEncoding(encodedString.toUtf8());
}

QString Utility::hasForumName(const QByteArray &link)
{
    QUrl url = QUrl::fromEncoded(link);
    QString kw;
    if (url.host().endsWith("tieba.baidu.com") && url.hasQueryItem("kw")){
        QList<QByteArray> path = url.encodedPath().split('/');
        if (path.contains("m") || url.queryItemValue("ie") == "utf-8"){
            kw = url.queryItemValue("kw");
        } else {
            QByteArray ba = url.encodedQueryItemValue("kw");
            q_fromPercentEncoding(&ba, '%');
            QTextCodec* codec = QTextCodec::codecForName("GBK");
            kw = codec->toUnicode(ba);
        }
    }
    return kw;
}

QString Utility::fixUrl(const QString &url) const
{
    const QString prefix = "http://tieba.baidu.com/mo/q/checkurl";
    if (url.startsWith(prefix)){
        QUrl temp(url);
        if (temp.hasEncodedQueryItem("url")){
            return QUrl::fromEncoded(temp.queryItemValue("url").toAscii()).toString();
        }
    }
    return url;
}

QString Utility::emoticonUrl(const QString &name) const
{
#ifdef Q_OS_HARMATTAN
    QString path("file:///opt/tbclient/");
#else
    QString path("file:///");
    path.append(QDir::currentPath()).append("/");
#endif

    if (name.startsWith("image_emoticon")||name.startsWith("write_face_")||name.startsWith("image_editoricon")||name.startsWith("i_f")){
        QRegExp reg("\\d+");
        int index = reg.indexIn(name) > -1 ? reg.cap().toInt() : 1;
        if (index == 1)
            return path.append("qml/emo/image_emoticon/image_emoticon.png");
        else if (index <= 50)
            return path.append("qml/emo/image_emoticon/image_emoticon").append(QString::number(index)).append(".png");
    } else if (name.startsWith("ali_") && name.mid(4).toInt() <= 70){
        return path.append("qml/emo/ali/").append(name).append(".png");
    } else if (name.startsWith("yz_") && name.mid(3).toInt() <= 46){
        return path.append("qml/emo/yz/").append(name).append(".png");
    } else if (name.startsWith("B_") && name.mid(2).toInt() <= 63){
        return path.append("qml/emo/b/").append(name.toLower()).append(".png");
    } else if (name.startsWith("b") && name.length() == 3 && name.mid(1).toInt() <= 62){
        return path.append("qml/emo/b0/").append(name).append(".png");
    } else if (name.startsWith("t_") && name.mid(2).toInt() <= 40){
        return path.append("qml/emo/t/").append(name).append(".png");
    }
    return QString();
}

QString Utility::emoticonText(const QString &name)
{
    if (m_emo.isEmpty()){
        initializeEmoticonHash();
    }
    return m_emo.value(name);
}

QStringList Utility::customEmoticonList()
{
    if (m_emolist.isEmpty()){
#ifdef Q_OS_HARMATTAN
        QFile file("/opt/tbclient/qml/emo/custom.dat");
#else
        QFile file("qml/emo/custom.dat");
#endif
        if (file.open(QIODevice::ReadOnly)){
            QTextStream out(&file);
            out.setCodec("UTF-8");
            QString str = out.readAll();
            file.close();
            m_emolist = str.split(",");
        }
    }
    return m_emolist;
}

// private
void Utility::initializeLangFormats()
{
    lang["ago"] = tr("ago");
    lang["from"] = tr("From Now");
    lang["now"] = tr("just now");
    lang["minute"] = tr("min");
    lang["minutes"] = tr("mins");
    lang["hour"] = tr("hr");
    lang["hours"] = tr("hrs");
    lang["day"] = tr("day");
    lang["days"] = tr("days");
    lang["week"] = tr("wk");
    lang["weeks"] = tr("wks");
    lang["month"] = tr("mth");
    lang["months"] = tr("mths");
    lang["year"] = tr("yr");
    lang["years"] = tr("yrs");

    QVariantList l1;
    l1 << 60 << lang["now"];
    QVariantList l2;
    l2 << 3600 << lang["minute"] << lang["minutes"] << 60;
    QVariantList l3;
    l3 << 86400 << lang["hour"] << lang["hours"] << 3600;
    QVariantList l4;
    l4 << 604800 << lang["day"] << lang["days"] << 86400;
    QVariantList l5;
    l5 << 2628000 << lang["week"] << lang["weeks"] << 604800;
    QVariantList l6;
    l6 << 31536000 << lang["month"] << lang["months"] << 2628000;
    QVariantList l7;
    l7 << INT_MAX << lang["year"] << lang["years"] << 31536000;

    formats << l1 << l2 << l3 << l4 << l5 << l6 << l7;
}

int Utility::normalize(int val, int single)
{
    int margin = 0.1;
    if (val >= single && val <= single*(1+margin))
        return single;
    return val;
}

bool Utility::deleteDir(const QString &dirName)
{
    QDir directory(dirName);
    if (!directory.exists())
    {
        return true;
    }
    QStringList files = directory.entryList(QDir::AllEntries | QDir::NoDotAndDotDot | QDir::Hidden);
    QList<QString>::iterator f = files.begin();
    bool error = false;
    for (; f != files.end(); ++f)
    {
        QString filePath = QDir::convertSeparators(directory.path() + '/' + (*f));
        QFileInfo fi(filePath);
        if (fi.isFile() || fi.isSymLink())
        {
            QFile::setPermissions(filePath, QFile::WriteOwner);
            if (!QFile::remove(filePath))
            {
#ifdef QT_DEBUG
                qDebug() << "Global::deleteDir 1" << filePath << "faild";
#endif
                error = true;
            }
        }
        else if (fi.isDir())
        {
            if (!deleteDir(filePath))
            {
                error = true;
            }
        }
    }
    return !error;
}

inline void Utility::q_fromPercentEncoding(QByteArray *ba, char percent)
{
    if (ba->isEmpty())
      return;

    char *data = ba->data();
    const char *inputPtr = data;

    int i = 0;
    int len = ba->count();
    int outlen = 0;
    int a, b;
    char c;
    while (i < len) {
      c = inputPtr[i];
      if (c == percent && i + 2 < len) {
        a = inputPtr[++i];
        b = inputPtr[++i];

        if (a >= '0' && a <= '9') a -= '0';
        else if (a >= 'a' && a <= 'f') a = a - 'a' + 10;
        else if (a >= 'A' && a <= 'F') a = a - 'A' + 10;

        if (b >= '0' && b <= '9') b -= '0';
        else if (b >= 'a' && b <= 'f') b  = b - 'a' + 10;
        else if (b >= 'A' && b <= 'F') b  = b - 'A' + 10;

        *data++ = (char)((a << 4) | b);
      } else {
        *data++ = c;
      }

      ++i;
      ++outlen;
    }

    if (outlen != len)
      ba->truncate(outlen);
}

void Utility::initializeEmoticonHash()
{
#ifdef Q_OS_HARMATTAN
    QFile file("/opt/tbclient/qml/emo/emo.dat");
#else
    QFile file("qml/emo/emo.dat");
#endif
    if (file.open(QIODevice::ReadOnly)){
        QTextStream out(&file);
        out.setCodec("UTF-8");
        QString text;

        out >> text;
        m_emo.insert("image_emoticon", text);

        for (int i=2; i<=50; i++){
            out >> text;
            m_emo.insert("image_emoticon"+QString::number(i), text);
        }

        for (int i=1; i<=62; i++){
            out >> text;
            m_emo.insert((i<10?"b0":"b")+QString::number(i), text);
        }

        for (int i=1; i<=70; i++){
            out >> text;
            m_emo.insert((i<10?"ali_00":"ali_0")+QString::number(i), text);
        }

        for (int i=1; i<=40; i++){
            out >> text;
            m_emo.insert((i<10?"t_000":"t_00")+QString::number(i), text);
        }

        for (int i=1; i<=46; i++){
            out >> text;
            m_emo.insert((i<10?"yz_00":"yz_0")+QString::number(i), text);
        }

        for (int i=1; i<=25; i++){
            out >> text;
            m_emo.insert((i<10?"B_000":"B_00")+QString::number(i), text);
        }

        file.close();
    }
}

#ifdef Q_OS_SYMBIAN
void Utility::LaunchAppL(const TUid aUid, HBufC* aParam)
{
    RWsSession ws;
    User::LeaveIfError(ws.Connect());
    CleanupClosePushL(ws);
    TApaTaskList taskList(ws);
    TApaTask task = taskList.FindApp(aUid);

    if(task.Exists())
    {
        task.BringToForeground();
        HBufC8* param8 = HBufC8::NewLC(aParam->Length());
        param8->Des().Append(*aParam);
        task.SendMessage(TUid::Null(), *param8); // UID not used, SwEvent capability need to be declared
        CleanupStack::PopAndDestroy(param8);
    }
    else
    {
        RApaLsSession apaLsSession;
        User::LeaveIfError(apaLsSession.Connect());
        CleanupClosePushL(apaLsSession);
        TThreadId thread;
        User::LeaveIfError(apaLsSession.StartDocument(*aParam, aUid, thread));
        CleanupStack::PopAndDestroy(1, &apaLsSession);
    }
    CleanupStack::PopAndDestroy(&ws);
}

void Utility::LaunchL(int id, const QString& param)
{
    //Coversion to Symbian C++ types
    TUid uid = TUid::Uid(id);
    TPtrC16 ptr(static_cast<const TUint16*>(param.utf16()), param.length());
    HBufC* desc_param = HBufC::NewLC(ptr.Length());
    desc_param->Des().Copy(ptr);

    LaunchAppL(uid, desc_param);

    CleanupStack::PopAndDestroy(desc_param);
}

QString Utility::CaptureImage()
{
    CNewFileServiceClient* fileClient = NewFileServiceFactory::NewClientL();
    CleanupStack::PushL(fileClient);

    CDesCArray* fileNames = new (ELeave) CDesCArrayFlat(1);
    CleanupStack::PushL(fileNames);

    CAiwGenericParamList* paramList = CAiwGenericParamList::NewLC();

    TAiwVariant variant(EFalse);
#ifdef Q_OS_S60V5
    TAiwGenericParam param1(170, variant);
#else
    TAiwGenericParam param1(EGenericParamMMSSizeLimit, variant);
#endif
    paramList->AppendL( param1 );

    TSize resolution = TSize(1600, 1200);
    TPckgBuf<TSize> buffer( resolution );
    TAiwVariant resolutionVariant( buffer );
#ifdef Q_OS_S60V5
    TAiwGenericParam param( 171, resolutionVariant );
#else
    TAiwGenericParam param( EGenericParamResolution, resolutionVariant );
#endif
    paramList->AppendL( param );

    const TUid KUidCamera = { 0x101F857A }; // Camera UID for S60 5th edition

    TBool result = fileClient->NewFileL( KUidCamera, *fileNames, paramList,
                                         ENewFileServiceImage, EFalse );

    QString ret;

    if (result) {
        TPtrC fileName=fileNames->MdcaPoint(0);
        ret = QString((QChar*) fileName.Ptr(), fileName.Length());
    }

    CleanupStack::PopAndDestroy(3);

    return ret;
}
QString Utility::LaunchLibrary()
{
    QString result;
    CDesCArray* fileNames = new(ELeave)CDesCArrayFlat(1);
    CleanupStack::PushL(fileNames);
    if (MGFetch::RunL(*fileNames, EImageFile, EFalse)){
        TPtrC fileName = fileNames->MdcaPoint(0);
        result = QString((QChar*) fileName.Ptr(), fileName.Length());
    }
    CleanupStack::PopAndDestroy(fileNames);
    return result;
}
QString Utility::LaunchLibrary2()
{
    QStringList result;
    CDesCArray* fileNames = new(ELeave)CDesCArrayFlat(10);
    CleanupStack::PushL(fileNames);
    if (MGFetch::RunL(*fileNames, EImageFile, ETrue)){
        for (int i=0; i<fileNames->MdcaCount(); i++){
            TPtrC fileName = fileNames->MdcaPoint(i);
            result.append(QString((QChar*) fileName.Ptr(), fileName.Length()));
        }
    }
    CleanupStack::PopAndDestroy(fileNames);
    return result.join("\n");
}
#endif

#ifdef Q_OS_HARMATTAN
void Utility::startCamera()
{
    QDBusConnection bus = QDBusConnection::sessionBus();
    bus.connect(CAMERA_SERVICE, "/", CAMERA_INTERFACE,
                "captureCanceled", this, SLOT(captureCanceled(QString)));
    bus.connect(CAMERA_SERVICE, "/", CAMERA_INTERFACE,
                "captureCompleted", this, SLOT(captureCompleted(QString,QString)));
    QDBusMessage message = QDBusMessage::createMethodCall(CAMERA_SERVICE, "/", CAMERA_INTERFACE, "showCamera");
    QVariantList arguments;
    uint someVar = 0;
    arguments << someVar << "" << "still-capture" << true;
    message.setArguments(arguments);
    QDBusMessage reply = bus.call(message);
    if (reply.type() == QDBusMessage::ErrorMessage){
        disconnectSignals();
    }
}

void Utility::disconnectSignals()
{
    QDBusConnection bus = QDBusConnection::sessionBus();
    bus.disconnect(CAMERA_SERVICE, "/", CAMERA_INTERFACE,
                   "captureCanceled", this, SLOT(captureCanceled(QString)));

    bus.disconnect(CAMERA_SERVICE, "/", CAMERA_INTERFACE,
                   "captureCompleted", this, SLOT(captureCompleted(QString,QString)));
}

void Utility::captureCompleted(const QString &mode, const QString &fileName)
{
    Q_UNUSED(mode)
    disconnectSignals();
    emit imageCaptured(fileName);
}

void Utility::captureCanceled(const QString &mode)
{
    Q_UNUSED(mode)
    disconnectSignals();
}

#endif
