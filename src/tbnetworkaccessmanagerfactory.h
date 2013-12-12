#ifndef TBNETWORKACCESSMANAGERFACTORY_H
#define TBNETWORKACCESSMANAGERFACTORY_H

#include <QtDeclarative>
#include <QtNetwork>

class TBNetworkAccessManagerFactory : public QDeclarativeNetworkAccessManagerFactory
{
public:
    explicit TBNetworkAccessManagerFactory();
    virtual QNetworkAccessManager* create(QObject *parent);

private:
    QMutex mutex;
};

class TBNetworkAccessManager : public QNetworkAccessManager
{
    Q_OBJECT
public:
    explicit TBNetworkAccessManager(QObject *parent = 0);

protected:
    QNetworkReply *createRequest(Operation op, const QNetworkRequest &request, QIODevice *outgoingData);
};

class TBNetworkCookieJar : public QNetworkCookieJar
{
public:
    static TBNetworkCookieJar* GetInstance();
    void clearCookies();

    virtual QList<QNetworkCookie> cookiesForUrl(const QUrl &url) const;
    virtual bool setCookiesFromUrl(const QList<QNetworkCookie> &cookieList, const QUrl &url);

private:
    explicit TBNetworkCookieJar(QObject *parent = 0);
    ~TBNetworkCookieJar();

    void save();
    void load();
    mutable QMutex mutex;
    QNetworkCookie keepAliveCookie;
};

#endif // TBNETWORKACCESSMANAGERFACTORY_H
