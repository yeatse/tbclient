#ifndef IMAGEUPLOADER_H
#define IMAGEUPLOADER_H

#include <QObject>
#include <QImageReader>
#include <QPointer>
#include "httpuploader.h"

class ImageUploadData;
class ImageUploader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QObject* uploader READ uploader WRITE setUploader NOTIFY uploaderChanged)
    Q_PROPERTY(qreal progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(bool isRunning READ isRunning NOTIFY isRunningChanged)

public:
    explicit ImageUploader(QObject *parent = 0);
    ~ImageUploader();

    QObject* uploader() const;
    void setUploader(const QObject* uploader);
    qreal progress() const;
    bool isRunning() const;

    Q_INVOKABLE void startUpload(const QString &fileName, const QVariantMap &extras);
    Q_INVOKABLE void abortUpload();

signals:
    void uploaderChanged();
    void progressChanged();
    void isRunningChanged();

    void uploadFinished(const QVariantMap &result);

private slots:
    void startSingleUpload();

private:
    QString generateResourceId(const QString &fileName);
    QString signForm(const QVariantMap &params);
    QVariantMap jsonParse(const QString &jsonData);

private slots:
    void slotProgressChanged();
    void slotStateChanged();

private:
    qreal mProgress;
    ImageUploadData* mData;
    QImageReader* mReader;
    QPointer<HttpUploader> mUploader;
};

#endif // IMAGEUPLOADER_H
