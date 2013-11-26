#ifndef DOWNLOADER_H
#define DOWNLOADER_H

#include <QObject>
#include <QThread>
#include <QtNetwork>
#include <QQueue>
#include <QDebug>

class DownloadHelper;

class Downloader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int state READ state NOTIFY stateChanged)
    Q_PROPERTY(qreal progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(int error READ error)

    Q_PROPERTY(QString currentFile READ currentFile NOTIFY currentRequestChanged)
    Q_PROPERTY(QString currentRequest READ currentRequest NOTIFY currentRequestChanged)

public:
    explicit Downloader(QObject *parent = 0);
    ~Downloader();

    int state() const;
    qreal progress() const;
    int error() const;

    QString currentFile() const;
    QString currentRequest() const;

    QString saveFileName(const QString &oriName);

    Q_INVOKABLE void appendDownload(const QString &url, const QString &filename);
    Q_INVOKABLE void abortDownload(const bool isAll = true);
    Q_INVOKABLE bool existsRequest(const QString &url);
    Q_INVOKABLE void removeRequest(const QString &url, const QString &filename);

private slots:
    void setState(int state);
    void setProgress(qreal progress);
    void setError(int error);

    void startNextDownload();

signals:
    void start(QUrl, QString);
    void abort();

    void stateChanged();
    void progressChanged();
    void currentRequestChanged();
    void currentFileChanged();

private:
    QPointer<DownloadHelper> dl;
    QPointer<QThread> thread;

    QQueue<QUrl> downloadQueue;
    QQueue<QString> fileNameQueue;

    int mState;
    qreal mProgress;
    int mError;
    QString mCurrentFile;
    QString mCurrentRequest;
};

class DownloadHelper : public QObject
{
    Q_OBJECT
public:
    explicit DownloadHelper(QObject *parent = 0);
    ~DownloadHelper();

    //state: Unsent - 0, Opened - 1, Loading - 2, Done - 3, Finished - 4
public slots:
    void start(QUrl source, QString target);
    void abort();

    void downloadProgress(qint64 bytesReceived, qint64 bytesTotal);
    void downloadFinished();
    void downloadReadyRead();

signals:
    void error(int);
    void stateChanged(int);
    void progressChanged(qreal);
    void finished();

private:
    QPointer<QNetworkAccessManager> manager;
    QPointer<QNetworkReply> currentDownload;
    QPointer<QFile> output;
};

#endif // DOWNLOADER_H
