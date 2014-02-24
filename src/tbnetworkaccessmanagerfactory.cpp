#include "tbnetworkaccessmanagerfactory.h"
#include "utility.h"

#define PORTRAIT_PREFIX "http://tb.himg.baidu.com/sys/portraitn/item/"
#define IMG_PREFIX "http://imgsrc.baidu.com/forum/pic/item/"
#define IMG_UNSUPPORTED_HOST "http://c.tieba.baidu.com/c/p/img"
#define HOST_PREFIX "http://c.tieba.baidu.com/"

TBNetworkAccessManagerFactory::TBNetworkAccessManagerFactory() :
    QDeclarativeNetworkAccessManagerFactory()
{
}

QNetworkAccessManager* TBNetworkAccessManagerFactory::create(QObject *parent)
{
    QMutexLocker lock(&mutex);
    Q_UNUSED(lock);
    QNetworkAccessManager* manager = new TBNetworkAccessManager(parent);

#ifdef Q_OS_SYMBIAN
    bool useDiskCache = Utility::Instance()->qtVersion() >= 0x040800;
#else
    bool useDiskCache = true;
#endif
    if (useDiskCache){
        QNetworkDiskCache* diskCache = new QNetworkDiskCache(parent);
        QString dataPath = QDesktopServices::storageLocation(QDesktopServices::CacheLocation);
        QDir dir(dataPath);
        if (!dir.exists()) dir.mkpath(dir.absolutePath());

        diskCache->setCacheDirectory(dataPath);
        diskCache->setMaximumCacheSize(3*1024*1024);
        manager->setCache(diskCache);
    }

    QNetworkCookieJar* cookieJar = TBNetworkCookieJar::GetInstance();
    manager->setCookieJar(cookieJar);
    cookieJar->setParent(0);

    return manager;
}

TBNetworkAccessManager::TBNetworkAccessManager(QObject *parent) :
    QNetworkAccessManager(parent)
{
}

QNetworkReply *TBNetworkAccessManager::createRequest(Operation op, const QNetworkRequest &request, QIODevice *outgoingData)
{
    QNetworkRequest req(request);
    // set user-agent
    if (op == PostOperation){
        req.setRawHeader("User-Agent", "IDP");
    } else {
        req.setRawHeader("User-Agent", "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53");
    }
    QByteArray urldata = req.url().toString().toAscii();
    // convert unsupported image url
    if (urldata.startsWith(IMG_UNSUPPORTED_HOST) && req.url().hasEncodedQueryItem("src")){
        urldata = req.url().encodedQueryItemValue("src");
        req.setUrl(QUrl::fromEncoded(urldata));
    }
    // set cache control
    if (urldata.startsWith(PORTRAIT_PREFIX) || urldata.startsWith(IMG_PREFIX)){
        req.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);
    } else {
        req.setAttribute(QNetworkRequest::CacheSaveControlAttribute, false);
    }
    QNetworkReply *reply = QNetworkAccessManager::createRequest(op, req, outgoingData);
    return reply;
}

TBNetworkCookieJar::TBNetworkCookieJar(QObject *parent) :
    QNetworkCookieJar(parent)
{
    keepAliveCookie = QNetworkCookie("ka", "open");
    load();
}

TBNetworkCookieJar::~TBNetworkCookieJar()
{
    save();
}

TBNetworkCookieJar* TBNetworkCookieJar::GetInstance()
{
    static TBNetworkCookieJar cookieJar;
    return &cookieJar;
}

void TBNetworkCookieJar::clearCookies()
{
    QList<QNetworkCookie> emptyList;
    setAllCookies(emptyList);
}

QList<QNetworkCookie> TBNetworkCookieJar::cookiesForUrl(const QUrl &url) const
{
    QMutexLocker lock(&mutex);
    Q_UNUSED(lock);
    QList<QNetworkCookie> cookies = QNetworkCookieJar::cookiesForUrl(url);
    if (url.toEncoded().startsWith(HOST_PREFIX) && !cookies.contains(keepAliveCookie))
        cookies.prepend(keepAliveCookie);
    return cookies;
}

bool TBNetworkCookieJar::setCookiesFromUrl(const QList<QNetworkCookie> &cookieList, const QUrl &url)
{
    QMutexLocker lock(&mutex);
    Q_UNUSED(lock);
    return QNetworkCookieJar::setCookiesFromUrl(cookieList, url);
}

void TBNetworkCookieJar::save()
{
    QMutexLocker lock(&mutex);
    Q_UNUSED(lock);
    QList<QNetworkCookie> list = allCookies();
    QByteArray data;
    foreach (QNetworkCookie cookie, list) {
        if (!cookie.isSessionCookie()){
            QString domain = cookie.domain();
            if (domain.endsWith("tieba.baidu.com")||domain.endsWith("wappass.baidu.com")||domain == ".baidu.com"){
                data.append(cookie.toRawForm());
                data.append("\n");
            }
        }
    }
    Utility::Instance()->setValue("cookies", data);
}

void TBNetworkCookieJar::load()
{
    QMutexLocker lock(&mutex);
    Q_UNUSED(lock);
    QByteArray data = Utility::Instance()->getValue("cookies").toByteArray();
    setAllCookies(QNetworkCookie::parseCookies(data));
}
