#include "utility.h"
#include "tbnetworkaccessmanagerfactory.h"

#include <QSystemDeviceInfo>
#include <QtNetwork>

#ifdef Q_OS_SYMBIAN
#include <akndiscreetpopup.h>       //for discreet popup
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
#include <maemo-meegotouch-interfaces/videosuiteinterface.h>
#include <maemo-meegotouch-interfaces/shareuiinterface.h>
#include <MDataUri>
#endif

Utility::Utility(QObject *parent) :
    QObject(parent)
{
    settings = new QSettings(this);
}

Utility::~Utility()
{
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
    if (engine.isNull()) return;
    QAbstractNetworkCache* diskCache = engine->networkAccessManager()->cache();
    if (diskCache == 0) return;
    diskCache->clear();
}

void Utility::openURLDefault(const QString &url)
{
#ifdef Q_OS_SYMBIAN
    const int KWmlBrowserUid = 0x10008D39;
    TRAP_IGNORE(LaunchL(KWmlBrowserUid, "4 "+url));
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

void Utility::showNotification(const QString &title, const QString &message) const
{
    QApplication::beep();
#ifdef Q_OS_SYMBIAN
    TPtrC16 sTitle(static_cast<const TUint16 *>(title.utf16()), title.length());
    TPtrC16 sMessage(static_cast<const TUint16 *>(message.utf16()), message.length());
    TUid uid = TUid::Uid(0x2006622A);
    TRAP_IGNORE(CAknDiscreetPopup::ShowGlobalPopupL(sTitle, sMessage, KAknsIIDNone, KNullDesC, 0, 0, KAknDiscreetPopupDurationLong, 0, NULL, uid));
#else
    qDebug() << "showNotification:" << title << message;
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
    qDebug() << encodedString;
    return "";
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
                qDebug() << "Global::deleteDir 1" << filePath << "faild";
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
    TPtrC ptr(static_cast<const TUint16*>(param.utf16()), param.length());
    HBufC* desc_param = HBufC::NewLC( param.length());
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
    TAiwGenericParam param1(EGenericParamMMSSizeLimit, variant);
    paramList->AppendL( param1 );

    TSize resolution = TSize(1600, 1200);
    TPckgBuf<TSize> buffer( resolution );
    TAiwVariant resolutionVariant( buffer );
    TAiwGenericParam param( EGenericParamResolution, resolutionVariant );
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
    HBufC* result = NULL;
    CDesCArrayFlat* fileArray = new(ELeave)CDesCArrayFlat(3);
    QString res;
    if (MGFetch::RunL(*fileArray, EImageFile, EFalse)){
        result = fileArray->MdcaPoint(0).Alloc();
        res = QString((QChar*)result->Des().Ptr(), result->Length());
    }
    return res;
}
QString Utility::LaunchLibrary2()
{
    HBufC* result = NULL;
    CDesCArrayFlat* fileArray = new(ELeave)CDesCArrayFlat(10);
    QStringList res;
    if (MGFetch::RunL(*fileArray, EImageFile, ETrue)){
        for (int i=0; i<fileArray->MdcaCount(); i++){
            result = fileArray->MdcaPoint(i).Alloc();
            res.append(QString((QChar*)result->Des().Ptr(), result->Length()));
        }
    }
    return res.join("\n");
}
#endif
