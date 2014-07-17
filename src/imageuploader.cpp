#include "imageuploader.h"
#include "utility.h"
#include <QFile>

class ImageUploadData
{
public:
    QString resourceId;
    QString BDUSS;
    QString phoneNewImei;
    int chunkNo;
    int height;
    int width;
    QString clientId;
    QString phoneImei;
    QString fileName;
};

ImageUploader::ImageUploader(QObject *parent) :
    QObject(parent),
    mProgress(0),
    mData(0),
    mUploader(0),
    mReader(new QImageReader())
{
}

ImageUploader::~ImageUploader()
{
    if (mData != 0){
        delete mData;
        mData = 0;
        abortUpload();
    }
    delete mReader;
}

QObject* ImageUploader::uploader() const
{
    return mUploader;
}

void ImageUploader::setUploader(const QObject *uploader)
{
    HttpUploader* u = qobject_cast<HttpUploader *>(uploader);
    if (u != 0){
        if (mUploader != 0){
            mUploader->disconnect();
        }
        mUploader = u;
        connect(mUploader, SIGNAL(progressChanged()), this, SLOT(slotProgressChanged()));
        connect(mUploader, SIGNAL(stateChanged()), this, SLOT(slotStateChanged()));
        emit uploaderChanged();
    }
}

qreal ImageUploader::progress() const
{
    return mProgress;
}

void ImageUploader::startUpload(const QString &fileName, const QVariantMap &extras)
{
    if (!QFile::exists(fileName))
        return;

    if (mData != 0){
        delete mData;
        mData = 0;
        abortUpload();
    }

    mReader->setFileName(fileName);
    if (!mReader->canRead() || !mReader->supportsOption(QImageIOHandler::Size))
        return;

    mData = new ImageUploadData;
    mData->BDUSS = extras.value("BDUSS").toString();
    mData->phoneNewImei = extras.value("_phone_newimei").toString();
    mData->clientId = extras.value("_client_id").toString();
    mData->phoneImei = Utility::Instance()->imei();
}

void ImageUploader::abortUpload()
{
}

void ImageUploader::slotProgressChanged()
{

}

void ImageUploader::slotStateChanged()
{

}
