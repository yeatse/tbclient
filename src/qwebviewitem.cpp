#include "qwebviewitem.h"

#include <QtGui/QGraphicsSceneMouseEvent>
#include <QtGui/QApplication>
#include <QtGui/QMessageBox>
#include <QtGui/QInputDialog>
#include <QtDeclarative/QDeclarativeEngine>
#include "flickcharm.h"
#include "utility.h"

WebPage::WebPage(QObject *parent)
    : QWebPage(parent)
{
#ifndef Q_WS_SIMULATOR
    connect(this, SIGNAL(featurePermissionRequested(QWebFrame*,QWebPage::Feature)),
            this, SLOT(acceptFeature(QWebFrame*,QWebPage::Feature)));
#endif
    setForwardUnsupportedContent(true);
}

WebPage::~WebPage()
{
}

bool WebPage::acceptNavigationRequest(QWebFrame *frame, const QNetworkRequest &request, NavigationType type)
{
    if (frame == 0){
        Utility::Instance()->openURLDefault(request.url().toString());
        return false;
    } else {
        return QWebPage::acceptNavigationRequest(frame, request, type);
    }
}

void WebPage::javaScriptAlert(QWebFrame *originatingFrame, const QString &msg)
{
    Q_UNUSED(originatingFrame)
    QMessageBox::information(0, tr("Javascript Alert - %1").arg(mainFrame()->url().host()), Qt::escape(msg), QMessageBox::Ok);
}

bool WebPage::javaScriptConfirm(QWebFrame *originatingFrame, const QString &msg)
{
    Q_UNUSED(originatingFrame)
    return QMessageBox::Yes == QMessageBox::information(0, tr("Javascript Confirm - %1").arg(mainFrame()->url().host()),
                                                        Qt::escape(msg), QMessageBox::Yes, QMessageBox::No);
}

bool WebPage::javaScriptPrompt(QWebFrame *originatingFrame, const QString &msg, const QString &defaultValue, QString *result)
{
    Q_UNUSED(originatingFrame)
    bool ok = false;
    QString x = QInputDialog::getText(0, tr("Javascript Prompt - %1").arg(mainFrame()->url().host()),
                                      Qt::escape(msg), QLineEdit::Normal, defaultValue, &ok);
    if (ok && result)
        *result = x;
    return ok;
}

bool WebPage::shouldInterruptJavaScript()
{
    return QMessageBox::Yes == QMessageBox::information(0, tr("Javascript Problem - %1").arg(mainFrame()->url().host()),
                                                        tr("The script on this page appears to have a problem. Do you want to stop the script?"),
                                                        QMessageBox::Yes, QMessageBox::No);
}

#ifndef Q_WS_SIMULATOR
void WebPage::acceptFeature(QWebFrame *frame, QWebPage::Feature feature)
{
    setFeaturePermission(frame, feature, QWebPage::PermissionGrantedByUser);
}
#endif

QWebViewProxyWidget::QWebViewProxyWidget(QGraphicsItem *parent)
    : QGraphicsProxyWidget(parent)
    , webView(0)
{
    init();
}

QWebViewProxyWidget::~QWebViewProxyWidget()
{
    webView->deleteLater();
}

void QWebViewProxyWidget::init()
{
    webView = new QWebView();
    webPage = new WebPage(webView);
    webView->setPage(webPage);

    charm = new FlickCharm(this);
    charm->activateOn(webView);

    webView->setAttribute(Qt::WA_OpaquePaintEvent, true);
    webView->setAttribute(Qt::WA_NoSystemBackground, true);
    webView->setAttribute(Qt::WA_InputMethodEnabled, true);

    QWebPage* page = webView->page();

    page->settings()->setAttribute(QWebSettings::JavascriptCanOpenWindows, true);
    page->settings()->setAttribute(QWebSettings::JavascriptCanAccessClipboard, true);
    page->settings()->setAttribute(QWebSettings::OfflineStorageDatabaseEnabled, true);
    page->settings()->setAttribute(QWebSettings::OfflineWebApplicationCacheEnabled, true);
    page->settings()->setAttribute(QWebSettings::LocalStorageEnabled, true);
    page->settings()->setAttribute(QWebSettings::LocalContentCanAccessRemoteUrls, true);

    this->setWidget(webView);
}

QWebView* QWebViewProxyWidget::view() const
{
    return webView;
}

QWebFrame* QWebViewProxyWidget::frame() const
{
    return webView->page()->mainFrame();
}

void QWebViewProxyWidget::lockMoving()
{
    charm->deactivateFrom(webView);
}

void QWebViewProxyWidget::unlockMoving()
{
    charm->activateOn(webView);
}

QWebViewDownloader::QWebViewDownloader(QObject *parent)
    : QObject(parent)
    , output(0)
{
}

QWebViewDownloader::~QWebViewDownloader()
{
    abort();
}

void QWebViewDownloader::abort()
{
    if (!currentDownload.isNull() && currentDownload->isRunning()){
        currentDownload->abort();
    }
}

void QWebViewDownloader::downloadStarted(QNetworkReply *reply)
{
    abort();
    currentDownload = reply;
    if (!output) output = new QFile(this);
    Utility *ut = Utility::Instance();
    // Specify the location to save file
    QString basename;
    if (currentDownload->hasRawHeader("Content-Disposition")){
        QByteArray disposition = currentDownload->rawHeader("Content-Disposition");
        int idx = disposition.indexOf("filename=");
        if (idx >= 0) basename = QString(disposition.mid(idx+9).replace("\"", ""));
    }
    if (basename.isEmpty()){
        QFileInfo info(reply->url().toString(QUrl::RemoveQuery));
        basename = info.baseName();
    }
#ifdef Q_OS_HARMATTAN
    QString location = "";
#else
    QString location = ut->getValue("imagePath", ut->defaultPictureLocation()).toString();
#endif
    if (!(location.endsWith("\\")||location.endsWith("/")))
        location.append(QDir::separator());
    location.append(basename);
    if (QFile::exists(location)) QFile::remove(location);
    output->setFileName(location + ".tmp");

    emit started();
    if (!output->open(QIODevice::WriteOnly)){
        downloadFinished();
    } else {
        ut->showNotification(tr("Download started"), location);
        connect(currentDownload.data(), SIGNAL(downloadProgress(qint64,qint64)), SLOT(downloadProgress(qint64,qint64)));
        connect(currentDownload.data(), SIGNAL(readyRead()), SLOT(downloadReadyRead()));
        connect(currentDownload.data(), SIGNAL(finished()), SLOT(downloadFinished()));
    }
}

void QWebViewDownloader::downloadProgress(qint64 bytesReceived, qint64 bytesTotal)
{
    QString progress = QString::number(round(bytesReceived/1024))+"kb/"+QString::number(round(bytesTotal/1024))+"kb";
    emit progressChanged(progress);
}

void QWebViewDownloader::downloadReadyRead()
{
    output->write(currentDownload->readAll());
}

void QWebViewDownloader::downloadFinished()
{
    currentDownload->deleteLater();
    bool ok = false;
    if (output->isOpen()){
        output->close();
        if (currentDownload->error()){
            output->remove();
        } else {
            QString fileName = output->fileName();
            int idx = fileName.lastIndexOf(".tmp");
            fileName = fileName.left(idx);
            output->rename(fileName);
            ok = true;
        }
    }
    Utility* ut = Utility::Instance();
    if (ok){
        ut->showNotification(tr("Download finished"), output->fileName());
#ifdef Q_OS_SYMBIAN
        TRAP_IGNORE(ut->LaunchL(0x101f84EB, output->fileName().replace("/","\\")));
#endif
    } else {
        ut->showNotification(tr("Download failed"), "");
    }
    emit finished();
}

QWebViewItem::QWebViewItem(QDeclarativeItem *parent) :
    QDeclarativeItem(parent)
{
    setFlag(QGraphicsItem::ItemHasNoContents, true);
    setFlag(QGraphicsItem::ItemIsFocusable, true);
    setAcceptDrops(true);
    setAcceptHoverEvents(true);
    setAcceptTouchEvents(true);
    setFlag(QGraphicsItem::ItemClipsChildrenToShape, true);
    init();
}

QWebViewItem::~QWebViewItem()
{
    proxy->deleteLater();
}

void QWebViewItem::init()
{
    proxy = new QWebViewProxyWidget(this);
    dl = new QWebViewDownloader(this);

    connect(proxy->view(), SIGNAL(urlChanged(QUrl)), SIGNAL(urlChanged()));
    connect(proxy->view(), SIGNAL(titleChanged(QString)), SIGNAL(titleChanged()));
    connect(proxy->view(), SIGNAL(loadStarted()), SIGNAL(loadStarted()));
    connect(proxy->view(), SIGNAL(loadFinished(bool)), SIGNAL(loadFinished(bool)));
    connect(proxy->view(), SIGNAL(loadProgress(int)), SLOT(doLoadProgress(int)));
    connect(proxy->frame(), SIGNAL(contentsSizeChanged(QSize)), SIGNAL(contentsSizeChanged()));

    connect(proxy->view()->page(), SIGNAL(unsupportedContent(QNetworkReply*)), dl, SLOT(downloadStarted(QNetworkReply*)));
    connect(proxy->view()->page(), SIGNAL(downloadRequested(QNetworkRequest)), SLOT(doDownload(QNetworkRequest)));
    connect(dl, SIGNAL(started()), SIGNAL(downloadStarted()));
    connect(dl, SIGNAL(finished()), SIGNAL(downloadFinished()));
    connect(dl, SIGNAL(progressChanged(QString)), SIGNAL(downloadProgress(QString)));

    connect(proxy->frame(), SIGNAL(loadFinished(bool)), SIGNAL(htmlChanged()));
}

void QWebViewItem::componentComplete()
{
    QDeclarativeItem::componentComplete();
    // Load url or html after component completed
    QWebPage* page = proxy->view()->page();
    page->setNetworkAccessManager(qmlEngine(this)->networkAccessManager());

    if (!m_pendingHtml.isEmpty()){
        setHtml(m_pendingHtml);
        m_pendingHtml.clear();
    } else if (!m_pendingUrl.isEmpty()){
        setUrl(m_pendingUrl);
        m_pendingUrl.clear();
    }
}

QUrl QWebViewItem::url() const
{
    return isComponentComplete() ? proxy->view()->url() : m_pendingUrl;
}

void QWebViewItem::setUrl(const QUrl &url)
{
    if (!isComponentComplete()){
        m_pendingUrl = url;
    } else if (this->url() != url){
        proxy->view()->load(url);
    }
}

QString QWebViewItem::html() const
{
    return isComponentComplete() ? proxy->frame()->toHtml() : m_pendingHtml;
}

void QWebViewItem::setHtml(const QString &html)
{
    if (!isComponentComplete()){
        m_pendingHtml = html;
    } else if (this->html() != html){
        proxy->view()->setHtml(html);
    }
}

QString QWebViewItem::title() const
{
    return proxy->view()->title();
}

QSize QWebViewItem::contentsSize() const
{
    return proxy->frame()->contentsSize();
}

qreal QWebViewItem::loadProgress() const
{
    return this->m_progress;
}

void QWebViewItem::doLoadProgress(int progress)
{
    if (m_progress == progress/100.0)
        return;
    m_progress = progress / 100.0;
    emit loadProgressChanged();
}

int QWebViewItem::defaultFontSize() const
{
    return proxy->view()->settings()->fontSize(QWebSettings::DefaultFontSize);
}

void QWebViewItem::setDefaultFontSize(const int &fontSize)
{
    proxy->view()->settings()->setFontSize(QWebSettings::DefaultFontSize, fontSize);
    proxy->view()->settings()->setFontSize(QWebSettings::DefaultFixedFontSize, fontSize);
    emit defaultFontSizeChanged();
}

QAction* QWebViewItem::reloadAction() const
{
    return proxy->view()->pageAction(QWebPage::Reload);
}

QAction* QWebViewItem::backAction() const
{
    return proxy->view()->pageAction(QWebPage::Back);
}

QAction* QWebViewItem::forwardAction() const
{
    return proxy->view()->pageAction(QWebPage::Forward);
}

QAction* QWebViewItem::stopAction() const
{
    return proxy->view()->pageAction(QWebPage::Stop);
}

void QWebViewItem::geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    // make the ugly scrollbar out of the view
    qreal w = newGeometry.width() + proxy->frame()->scrollBarGeometry(Qt::Vertical).width();
    qreal h = newGeometry.height() + proxy->frame()->scrollBarGeometry(Qt::Horizontal).height();
    proxy->setGeometry(QRectF(newGeometry.x(), newGeometry.y(), w, h));
    proxy->view()->page()->setPreferredContentsSize(newGeometry.size().toSize());
    QDeclarativeItem::geometryChanged(newGeometry, oldGeometry);
}

void QWebViewItem::lockMoving()
{
    proxy->lockMoving();
}

void QWebViewItem::unlockMoving()
{
    proxy->unlockMoving();
}

void QWebViewItem::doDownload(const QNetworkRequest &request)
{
    QNetworkReply* reply = qmlEngine(this)->networkAccessManager()->get(request);
    dl->downloadStarted(reply);
}

void QWebViewItem::abortDownload()
{
    dl->abort();
}

bool QWebViewItem::sceneEvent(QEvent *event)
{
    if (event->type() == QEvent::TouchBegin
            || event->type() == QEvent::TouchEnd
            || event->type() == QEvent::TouchUpdate)
    {
        if (event->type() == QEvent::TouchBegin)
            setFocus(true);

        return proxy->view()->event(event);
    }
    return QDeclarativeItem::sceneEvent(event);
}

QVariant QWebViewItem::inputMethodQuery(Qt::InputMethodQuery query) const
{
    return proxy->view()->page()->inputMethodQuery(query);
}

void QWebViewItem::inputMethodEvent(QInputMethodEvent *event)
{
    QInputMethodEvent* ev = new QInputMethodEvent(*event);
    QApplication::postEvent(proxy->view()->page(), ev);
}

void QWebViewItem::keyPressEvent(QKeyEvent *event)
{
    QKeyEvent* ev = new QKeyEvent(event->type(),
                                  event->key(),
                                  event->modifiers(),
                                  event->text(),
                                  event->isAutoRepeat(),
                                  event->count());
    QApplication::postEvent(proxy->view()->page(), ev);
}

void QWebViewItem::keyReleaseEvent(QKeyEvent *event)
{
    QKeyEvent* ev = new QKeyEvent(event->type(),
                                  event->key(),
                                  event->modifiers(),
                                  event->text(),
                                  event->isAutoRepeat(),
                                  event->count());
    QApplication::postEvent(proxy->view()->page(), ev);
}
