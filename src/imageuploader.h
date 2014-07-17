#ifndef IMAGEUPLOADER_H
#define IMAGEUPLOADER_H

#include <QObject>
#include <QImageReader>
#include "httpuploader.h"

class ImageUploadData;
class ImageUploader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QObject* uploader READ uploader WRITE setUploader NOTIFY uploaderChanged)
    Q_PROPERTY(qreal progress READ progress NOTIFY progressChanged)

public:
    explicit ImageUploader(QObject *parent = 0);
    ~ImageUploader();

    QObject* uploader() const;

    void setUploader(const QObject* uploader);

    qreal progress() const;

    Q_INVOKABLE void startUpload(const QString &fileName, const QVariantMap &extras);

    Q_INVOKABLE void abortUpload();

signals:
    void progressChanged();
    void uploaderChanged();
    void uploadFinished(const QVariantMap &result);

private slots:
    void slotProgressChanged();
    void slotStateChanged();

private:
    qreal mProgress;
    ImageUploadData* mData;
    HttpUploader* mUploader;
    QImageReader* mReader;
};

#endif // IMAGEUPLOADER_H
