#include "imageuploader.h"
#include "utility.h"
#include <QFile>
#include <QCryptographicHash>

class ImageUploadData
{
public:
    static const int CHUNK_SIZE;
    static const char* UPLOAD_URL;

    QString resourceId;
    QString BDUSS;
    QString fileName;
    int width;
    int height;
    int chunkNo;
    int chunkCount;
};

const int ImageUploadData::CHUNK_SIZE = 51200;   // 50kb
const char* ImageUploadData::UPLOAD_URL = "http://c.tieba.baidu.com/c/s/uploadPicture";

ImageUploader::ImageUploader(QObject *parent) :
    QObject(parent),
    mProgress(0),
    mData(0),
    mReader(new QImageReader()),
    mUploader(0)
{
    connect(this, SIGNAL(uploadFinished(QVariantMap)), SIGNAL(isRunningChanged()));
}

ImageUploader::~ImageUploader()
{
    if (mData != 0){
        delete mData;
    }
    delete mReader;
}

QObject* ImageUploader::uploader() const
{
    return mUploader.data();
}

void ImageUploader::setUploader(const QObject *uploader)
{
    HttpUploader* u =  const_cast<HttpUploader*>(qobject_cast<const HttpUploader *>(uploader));
    if (u != 0){
        if (mUploader != 0){
            mUploader->disconnect();
        }
        mUploader = u;
        connect(mUploader, SIGNAL(progressChanged()), this, SLOT(slotProgressChanged()));
        connect(mUploader, SIGNAL(stateChanged()), this, SLOT(slotStateChanged()));
        emit uploaderChanged();
        emit isRunningChanged();
    }
}

qreal ImageUploader::progress() const
{
    return mProgress;
}

bool ImageUploader::isRunning() const
{
    return mUploader != 0 && mUploader->state() == HttpUploader::Loading;
}

void ImageUploader::startUpload(const QString &fileName, const QVariantMap &extras)
{
    if (!QFile::exists(fileName))
        return;

    mReader->setFileName(fileName);
    if (!mReader->canRead() || !mReader->supportsOption(QImageIOHandler::Size))
        return;

    if (mUploader == 0)
        return;

    if (mData != 0)
        delete mData;

    QFileInfo info(fileName);
    if (info.size() > 0x160000 || mReader->size().width() > 1200){
        int width = qMin(1200, mReader->size().width());
        int height = 1200 * mReader->size().height() / mReader->size().width();
        mReader->setScaledSize(QSize(width, height));
        QImage scaledImage = mReader->read();
        if (scaledImage.isNull())
            return;

        QString tempFileName = Utility::Instance()->tempPath().append(QDir::separator()).append("temp.jpg");
        if (!scaledImage.save(tempFileName))
            return;

        info.setFile(tempFileName);
        mReader->setFileName(tempFileName);
    }

    mData = new ImageUploadData;
    mData->resourceId = generateResourceId(info.filePath());
    mData->BDUSS = extras.value("BDUSS").toString();
    mData->fileName = info.filePath();
    mData->width = mReader->size().width();
    mData->height = mReader->size().height();
    mData->chunkNo = 0;
    mData->chunkCount = qCeil((qreal)info.size() / ImageUploadData::CHUNK_SIZE);

    QTimer::singleShot(0, this, SLOT(startSingleUpload()));
}

void ImageUploader::abortUpload()
{
    if (mData != 0){
        delete mData;
        mData = 0;
    }
    if (!mUploader.isNull()){
        mUploader->abort();
    }
}

void ImageUploader::startSingleUpload()
{
    if (mData == 0 || mData->chunkNo >= mData->chunkCount){
        emit uploadFinished(QVariantMap());
        return;
    }

    if (mUploader->state() != HttpUploader::Unsent){
        if (mUploader->state() == HttpUploader::Loading){
            mUploader->abort();
        }
        mUploader->clear();
    }

    Utility* u = Utility::Instance();
    QString chunkFileName = u->tempPath().append(QDir::separator()).append("image_chunk_")
            .append(QString::number(mData->chunkNo));

    bool ok = false;
    QFile inFile(mData->fileName);
    if (inFile.open(QIODevice::ReadOnly)){
        QFile outFile(chunkFileName);
        if (outFile.exists())
            outFile.remove();
        if (outFile.open(QIODevice::WriteOnly)){
            if (inFile.seek(mData->chunkNo * ImageUploadData::CHUNK_SIZE)){
                QByteArray chunkData = inFile.read(ImageUploadData::CHUNK_SIZE);
                outFile.write(chunkData);
                ok = true;
            }
            outFile.close();
        }
        inFile.close();
    }

    if (!ok){
        emit uploadFinished(QVariantMap());
        return;
    }

    QVariantMap params;
    params.insert("resourceId", mData->resourceId);
    params.insert("BDUSS", mData->BDUSS);
    params.insert("_timestamp", QDateTime::currentMSecsSinceEpoch());
    params.insert("_phone_newimei", QString(QCryptographicHash::hash(u->imei().toAscii(), QCryptographicHash::Md5).toHex().toUpper()));
    params.insert("chunkNo", mData->chunkNo + 1);
    params.insert("height", mData->height);
    params.insert("alt", "json");
    params.insert("width", mData->width);
    params.insert("_client_version", "6.0.1");
    params.insert("cuid", params.value("_phone_newimei"));
    params.insert("_client_id", u->getValue("clientId"));
    params.insert("_client_type", 1);
    params.insert("from", "appstore");
    params.insert("m_api", "/c/f/pb/page");
    params.insert("smallHeight", 0);
    params.insert("_phone_imei", params.value("_phone_newimei"));
    params.insert("smallWidth", 0);
    params.insert("isFinish", mData->chunkNo == mData->chunkCount - 1 ? 1 : 0);
    params.insert("net_type", 3);
    params.insert("sign", signForm(params));

    mUploader->open(QUrl(QString(ImageUploadData::UPLOAD_URL)));
    QVariantMap::const_iterator i = params.constBegin();
    while (i != params.constEnd()) {
        mUploader->addField(i.key(), i.value().toString());
        ++i;
    }
    mUploader->addFile("chunk", chunkFileName);
    mUploader->send();
}

QString ImageUploader::generateResourceId(const QString &fileName)
{
    QFile file(fileName);
    QByteArray hashData;
    if (file.open(QIODevice::ReadOnly)){
        if (file.size() > ImageUploadData::CHUNK_SIZE){
            hashData = file.read(ImageUploadData::CHUNK_SIZE);
        } else {
            hashData = file.readAll();
        }
        file.close();
    } else {
        hashData = fileName.toAscii();
    }
    return QString(QCryptographicHash::hash(hashData, QCryptographicHash::Md5).toHex().toUpper());
}

QString ImageUploader::signForm(const QVariantMap &params)
{
    QVariant result;
    QMetaObject::invokeMethod(this, "signForm", Q_RETURN_ARG(QVariant, result), Q_ARG(QVariant, params));
    return result.toString();
}

QVariantMap ImageUploader::jsonParse(const QString &jsonData)
{
    QVariant result;
    QMetaObject::invokeMethod(this, "jsonParse", Q_RETURN_ARG(QVariant, result), Q_ARG(QVariant, jsonData));
    return result.toMap();
}

void ImageUploader::slotProgressChanged()
{
    qreal newProgress;
    if (mData == 0 || mData->chunkCount <= 0)
        newProgress = 0;
    else {
        qreal chunkShare = 100.0/mData->chunkCount;
        newProgress = chunkShare * (mData->chunkNo + mUploader->progress());
        newProgress = (int)newProgress / 100.0;
    }
    if (newProgress != mProgress){
        mProgress = newProgress;
        emit progressChanged();
    }
}

void ImageUploader::slotStateChanged()
{
    if (mUploader->state() == HttpUploader::Loading)
        emit isRunningChanged();
    else if (mUploader->state() == HttpUploader::Done){
        if (mUploader->status() != 200){
            emit uploadFinished(QVariantMap());
        } else {
            QVariantMap resp = jsonParse(mUploader->responseText());
            if (resp.value("error_code").toString() == "0"){
                if (resp.contains("picId")){
                    QVariantMap result;
                    result.insert("success", true);
                    result.insert("picId", resp.value("picId"));
                    result.insert("width", mData->width);
                    result.insert("height", mData->height);
                    emit uploadFinished(result);
                } else {
                    mData->chunkNo = resp.value("chunkNo").toInt() - 1;
                    QTimer::singleShot(0, this, SLOT(startSingleUpload()));
                }
            } else if (resp.value("error_code").toString() == "2230203"){
                if (resp.contains("chunkNo")){
                    mData->chunkNo = resp.value("chunkNo").toInt() - 1;
                    QTimer::singleShot(0, this, SLOT(startSingleUpload()));
                } else {
                    emit uploadFinished(QVariantMap());
                }
            } else {
                emit uploadFinished(QVariantMap());
            }
        }
    }
}
