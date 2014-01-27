#ifndef QWEBVIEWITEM_H
#define QWEBVIEWITEM_H

#include <QtDeclarative/QDeclarativeItem>
#include <QtGui/QGraphicsProxyWidget>
#include <QtCore/QUrl>
#include <QtCore/QPointer>
#include <QtCore/QFile>
#include <QtWebKit/QWebPage>
#include <QtWebKit/QWebView>
#include <QtWebKit/QWebFrame>

class FlickCharm;

class WebPage : public QWebPage
{
    Q_OBJECT

public:
    explicit WebPage(QObject *parent = 0);
    ~WebPage();

public slots:
    bool shouldInterruptJavaScript();

protected:
    bool acceptNavigationRequest(QWebFrame *frame, const QNetworkRequest &request, NavigationType type);
    void javaScriptAlert(QWebFrame *originatingFrame, const QString &msg);
    bool javaScriptConfirm(QWebFrame *originatingFrame, const QString &msg);
    bool javaScriptPrompt(QWebFrame *originatingFrame, const QString &msg, const QString &defaultValue, QString *result);

private slots:
#ifndef Q_WS_SIMULATOR
    void acceptFeature(QWebFrame* frame, QWebPage::Feature feature);
#endif
};


class QWebViewProxyWidget : public QGraphicsProxyWidget
{
    Q_OBJECT
public:
    explicit QWebViewProxyWidget(QGraphicsItem *parent = 0);
    ~QWebViewProxyWidget();

    QWebView* view() const;
    QWebFrame* frame() const;

    void lockMoving();
    void unlockMoving();

private:
    void init();

private:
    QWebView* webView;
    QWebPage* webPage;
    FlickCharm* charm;
};

class QWebViewDownloader : public QObject
{
    Q_OBJECT
public:
    explicit QWebViewDownloader(QObject *parent = 0);
    ~QWebViewDownloader();

    void abort();
signals:
    void started();
    void finished();
    void progressChanged(QString progress);

public slots:
    void downloadStarted(QNetworkReply* reply);

private slots:
    void downloadProgress(qint64 bytesReceived, qint64 bytesTotal);
    void downloadReadyRead();
    void downloadFinished();

private:
    QPointer<QNetworkReply> currentDownload;
    QFile* output;
};

class QWebViewItem : public QDeclarativeItem
{
    Q_OBJECT
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(QString html READ html WRITE setHtml NOTIFY htmlChanged)
    Q_PROPERTY(QSize contentsSize READ contentsSize NOTIFY contentsSizeChanged)
    Q_PROPERTY(qreal loadProgress READ loadProgress NOTIFY loadProgressChanged)
    Q_PROPERTY(QString title READ title NOTIFY titleChanged)
    Q_PROPERTY(int defaultFontSize READ defaultFontSize WRITE setDefaultFontSize NOTIFY defaultFontSizeChanged)

    Q_PROPERTY(QAction* reload READ reloadAction CONSTANT)
    Q_PROPERTY(QAction* back READ backAction CONSTANT)
    Q_PROPERTY(QAction* forward READ forwardAction CONSTANT)
    Q_PROPERTY(QAction* stop READ stopAction CONSTANT)

public:
    explicit QWebViewItem(QDeclarativeItem *parent = 0);
    ~QWebViewItem();

    QUrl url() const;
    void setUrl(const QUrl &url);
    QString html() const;
    void setHtml(const QString &html);
    QString title() const;
    QSize contentsSize() const;
    qreal loadProgress() const;
    int defaultFontSize() const;
    void setDefaultFontSize(const int &fontSize);

    QAction *reloadAction() const;
    QAction *backAction() const;
    QAction *forwardAction() const;
    QAction *stopAction() const;

    Q_INVOKABLE void lockMoving();
    Q_INVOKABLE void unlockMoving();
    Q_INVOKABLE void abortDownload();

signals:
    void urlChanged();
    void htmlChanged();
    void titleChanged();
    void contentsSizeChanged();
    void loadProgressChanged();
    void defaultFontSizeChanged();

    void loadStarted();
    void loadFinished(bool ok);

    void downloadStarted();
    void downloadFinished();
    void downloadProgress(QString progress);

protected:
    void geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry);
    bool sceneEvent(QEvent *event);
    QVariant inputMethodQuery(Qt::InputMethodQuery query) const;
    void inputMethodEvent(QInputMethodEvent *event);
    void keyPressEvent(QKeyEvent *event);
    void keyReleaseEvent(QKeyEvent *event);

private:
    void init();
    void componentComplete();

private slots:
    void doLoadProgress(int progress);
    void doDownload(const QNetworkRequest &request);

private:
    QWebViewProxyWidget* proxy;
    QWebViewDownloader* dl;

    QUrl m_pendingUrl;
    QString m_pendingHtml;
    qreal m_progress;
};
#endif // QWEBVIEWITEM_H
