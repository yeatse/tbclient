/* Copyright 2011 Jarek Pelczar <jpelczar@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "httpuploader.h"
#include <QDebug>

class HttpUploaderDevice : public QIODevice
{
    Q_OBJECT
public:
    HttpUploaderDevice(HttpUploader * uploader):
        QIODevice(uploader),
        totalSize(0),
        ioIndex(0),
        lastIndex(0)
    {
        setup();
    }

    ~HttpUploaderDevice()
    {
        for(int i = 0 ; i < ioDevices.count() ; ++i)
            delete ioDevices[i].second;
    }

    virtual qint64 size() const;
    virtual bool seek(qint64 pos);

private:
    virtual qint64 readData(char *data, qint64 maxlen);
    virtual qint64 writeData(const char *data, qint64 len);

private:
    void setup();

public:
    struct Range {
        int start;
        int end;
    };

    void appendData(const QByteArray& data);
    void appendField(HttpPostField * field);

    QVector< QPair<Range, QIODevice *> > ioDevices;
    int totalSize;
    qint64 ioIndex;
    int lastIndex;
    QByteArray contentType;
};

qint64 HttpUploaderDevice::size() const
{
    return totalSize;
}

bool HttpUploaderDevice::seek(qint64 pos)
{
    if(pos >= totalSize)
        return false;
    ioIndex = pos;
    lastIndex = 0;
    return QIODevice::seek(pos);
}

qint64 HttpUploaderDevice::readData(char *data, qint64 len)
{
    if ((len = qMin(len, qint64(totalSize) - ioIndex)) <= 0)
        return qint64(0);

    qint64 totalRead = 0;

    while(len > 0)
    {
        if( ioIndex >= ioDevices[lastIndex].first.start &&
            ioIndex <= ioDevices[lastIndex].first.end )
        {

        } else {
            for(int i = 0 ; i < ioDevices.count() ; ++i)
            {
                if( ioIndex >= ioDevices[i].first.start &&
                    ioIndex <= ioDevices[i].first.end )
                {
                    lastIndex = i;
                }
            }
        }

        QIODevice * chunk = ioDevices[lastIndex].second;

        if(!ioDevices[lastIndex].second->seek(ioIndex - ioDevices[lastIndex].first.start))
        {
            qWarning("HttpUploaderDevice: Failed to seek inner device");
            break;
        }

        qint64 bytesLeftInThisChunk = chunk->size() - chunk->pos();
        qint64 bytesToReadInThisRequest = qMin(bytesLeftInThisChunk, len);

        qint64 readLen = chunk->read(data, bytesToReadInThisRequest);
        if( readLen != bytesToReadInThisRequest ) {
            qWarning("HttpUploaderDevice: Failed to read requested amount of data");
            break;
        }

//#ifdef QT_DEBUG
//        qDebug() << "HttpUploaderDevice: Read chunk of size" << readLen << "Offset =" << ioIndex << "Left =" << len - readLen;
//        qDebug() << "HttpUploaderDevice: Data is [" << QByteArray::fromRawData(data, readLen) << "]";
//#endif

        data += bytesToReadInThisRequest;
        len -= bytesToReadInThisRequest;
        totalRead += bytesToReadInThisRequest;
        ioIndex += bytesToReadInThisRequest;
    }

    return totalRead;
}

qint64 HttpUploaderDevice::writeData(const char *data, qint64 len)
{
    return -1;
}

void HttpUploaderDevice::setup()
{
#ifdef QT_DEBUG
    qDebug() << "HttpUploaderDevice: Setup device";
#endif

    HttpUploader * o = (HttpUploader *)parent();

    QByteArray crlf("\r\n");
    QByteArray boundary("---------------------------" + o->mBoundaryString);
    QByteArray endBoundary(crlf + "--" + boundary + "--" + crlf);
    contentType = QByteArray("multipart/form-data; boundary=") + boundary;
    boundary="--"+boundary+crlf;
    QByteArray bond=boundary;

    bool first = true;

    for(int i = 0 ; i < o->mPostFields.count() ; ++i)
    {
        if(!o->mPostFields[i])
            continue;
        HttpPostField * field = o->mPostFields[i].data();

        QByteArray chunk(bond);
        if(first) {
            first = false;
            boundary = crlf + boundary;
            bond = boundary;
        }

        if(field->type() == HttpPostField::FieldFile) {
            chunk.append("Content-Disposition: form-data; name=\"");
            chunk.append(field->name().toAscii());
            chunk.append("\"; filename=\"");

            HttpPostFieldFile * file = static_cast<HttpPostFieldFile *>(field);

            QFileInfo fi(file->source().toLocalFile());
            chunk.append(fi.fileName().toUtf8());
            chunk.append("\"");
            chunk.append(crlf);

            if(!file->mimeType().isEmpty()) {
                chunk.append("Content-Type: ");
                chunk.append(file->mimeType());
                chunk.append("\r\n");
            } else {
                chunk.append("Content-Type: application/octet-stream\r\n");
            }

            chunk.append(crlf);

            // Files up to 256KB may be loaded into memory
            if( totalSize + chunk.size() + file->contentLength() < 256*1024) {
                QIODevice * dev = file->createIoDevice(this);
                chunk.append(dev->readAll());
                delete dev;
                appendData(chunk);
            } else {
                appendData(chunk);
                appendField(file);
            }
        } else {
            chunk.append("Content-Disposition: form-data; name=\"");
            chunk.append(field->name().toAscii());
            chunk.append("\"");
            chunk.append(crlf);
            chunk.append("Content-Transfer-Encoding: 8bit");
            chunk.append(crlf);
            chunk.append(crlf);

            HttpPostFieldValue * value = static_cast<HttpPostFieldValue *>(field);

            chunk.append(value->value().toUtf8());

            appendData(chunk);
        }
    }

    if( !o->mPostFields.isEmpty() )
        appendData(endBoundary);

#ifdef QT_DEBUG
    qDebug() << "Total content length is" << totalSize;
#endif
}

void HttpUploaderDevice::appendData(const QByteArray& data)
{
#ifdef QT_DEBUG
    qDebug() << "HttpUploaderDevice: Append chunk of size" << data.size();
#endif

    QBuffer * buffer = new QBuffer(this);
    buffer->setData(data);
    buffer->open(QBuffer::ReadOnly);

    Range r;
    r.start = totalSize;
    r.end = totalSize + data.size() - 1;

    ioDevices.append(QPair<Range, QIODevice *>(r, buffer));
    totalSize += data.size();
}

void HttpUploaderDevice::appendField(HttpPostField * field)
{
#ifdef QT_DEBUG
    qDebug() << "HttpUploaderDevice: Append field of size" << field->contentLength();
#endif

    QIODevice * device = field->createIoDevice(this);

    Range r;
    r.start = totalSize;
    r.end = totalSize + device->size() - 1;

    ioDevices.append(QPair<Range, QIODevice *>(r, device));
    totalSize += device->size();
}

HttpPostField::HttpPostField(QObject * parent)
    : QObject(parent),
      mType(FieldInvalid),
      mInstancedFromQml(true)
{
}

HttpPostField::~HttpPostField()
{
#ifdef QT_DEBUG
    qDebug() << "HttpPostField::~HttpPostField()" << this;
#endif
}

QString HttpPostField::name() const
{
    return mName;
}

void HttpPostField::setName(const QString& name)
{
    if( mName != name ) {
        mName = name;
        emit nameChanged();
    }
}

HttpPostField::FieldType HttpPostField::type() const
{
    return mType;
}

void HttpPostField::setType(HttpPostField::FieldType type)
{
    mType = type;
}

HttpPostFieldValue::HttpPostFieldValue(QObject * parent)
    : HttpPostField(parent)
{
    mType = FieldValue;
}

QString HttpPostFieldValue::value() const
{
    return QString::fromUtf8(mValue.constData(), mValue.size());
}

void HttpPostFieldValue::setValue(const QString& value)
{
    mValue = value.toUtf8();
}

int HttpPostFieldValue::contentLength()
{
    return mValue.size();
}

QIODevice * HttpPostFieldValue::createIoDevice(QObject * parent)
{
    QBuffer * buffer = new QBuffer(parent);
    buffer->setData(mValue);
    buffer->open(QIODevice::ReadOnly);
    return buffer;
}

bool HttpPostFieldValue::validateVield()
{
    return true;
}

HttpPostFieldFile::HttpPostFieldFile(QObject * parent)
    : HttpPostField(parent)
{
    mType = FieldFile;
}

int HttpPostFieldFile::contentLength()
{
    QFileInfo fi(mSource.toLocalFile());
    return fi.size();
}

QIODevice * HttpPostFieldFile::createIoDevice(QObject * parent)
{
    QFile * file = new QFile(mSource.toLocalFile(), parent);
    if(!file->open(QFile::ReadOnly))
    {
        delete file;
        Q_ASSERT_X(NULL, "HttpPostFieldFile::createIoDevice", "Failed to open file");
    }
    return file;
}

QUrl HttpPostFieldFile::source() const
{
    return mSource;
}

void HttpPostFieldFile::setSource(const QUrl& url)
{
    mSource = url;
}

QString HttpPostFieldFile::mimeType() const
{
    return mMime;
}

void HttpPostFieldFile::setMimeType(const QString& mime)
{
    if( mMime != mime ) {
        mMime = mime;
        emit mimeTypeChanged();
    }
}

bool HttpPostFieldFile::validateVield()
{
    return QFile::exists(mSource.toLocalFile());
}

HttpUploader::HttpUploader(QObject *parent) :
    QObject(parent),
    mProgress(0.0),
    mState(Unsent),
    mPendingReply(NULL),
    mUploadDevice(NULL),
    mStatus(0)
{
    mComplete = false;
}

HttpUploader::~HttpUploader()
{
    if(mPendingReply) {
        mPendingReply->abort();
    }
}

QUrl HttpUploader::url() const
{
    return mUrl;
}

void HttpUploader::setUrl(const QUrl& url)
{
    if( mState == Loading )
    {
        qWarning() << "HttpUploader: Can't change URL in loading state";
    } else {
        if( url != mUrl ) {
            mUrl = url;
            emit urlChanged();
        }
    }
}

QDeclarativeListProperty<HttpPostField> HttpUploader::postFields()
{
    return QDeclarativeListProperty<HttpPostField>(this,
                                                   0,
                                                   &HttpUploader::AppendFunction,
                                                   &HttpUploader::CountFunction,
                                                   &HttpUploader::AtFunction,
                                                   &HttpUploader::ClearFunction);
}

void HttpUploader::AppendFunction(QDeclarativeListProperty<HttpPostField> * o, HttpPostField* field)
{
    HttpUploader * self = qobject_cast<HttpUploader *>(o->object);
    if(self) {
        if( self->mState == Loading ) {
            qWarning("HttpUploader: Invalid state when trying to append field");
        } else {
            self->mPostFields.append(field);
        }
    }
}

int HttpUploader::CountFunction(QDeclarativeListProperty<HttpPostField> * o)
{
    HttpUploader * self = qobject_cast<HttpUploader *>(o->object);
    if(self)
        return self->mPostFields.count();
    return 0;
}

HttpPostField * HttpUploader::AtFunction(QDeclarativeListProperty<HttpPostField> * o, int index)
{
    HttpUploader * self = qobject_cast<HttpUploader *>(o->object);
    if(self)
    {
        return self->mPostFields.value(index);
    }

    return NULL;
}

void HttpUploader::ClearFunction(QDeclarativeListProperty<HttpPostField> * o)
{
    HttpUploader * self = qobject_cast<HttpUploader *>(o->object);
    if(self)
    {
        if( self->mState == Loading ) {
            qWarning("HttpUploader: Invalid state when trying to clear fields");
        } else {
            for(int i = 0 ; i < self->mPostFields.size() ; ++i)
                if(self->mPostFields[i] && !self->mPostFields[i]->mInstancedFromQml)
                    delete self->mPostFields[i];
            self->mPostFields.clear();
        }
    }
}

void HttpUploader::classBegin()
{
    QDeclarativeEngine * engine = qmlEngine(this);

    if(QDeclarativeNetworkAccessManagerFactory * factory = engine->networkAccessManagerFactory())
    {
        mNetworkAccessManager = factory->create(this);
    } else {
        mNetworkAccessManager = engine->networkAccessManager();
    }
}

void HttpUploader::componentComplete()
{
    mComplete = true;
}

qreal HttpUploader::progress() const
{
    return mProgress;
}

HttpUploader::State HttpUploader::state() const
{
    return mState;
}

QString HttpUploader::errorString() const
{
    return mErrorString;
}

QString HttpUploader::responseText() const
{
    return QString::fromUtf8(mResponse.constData(), mResponse.size());
}

int HttpUploader::status() const
{
    return mStatus;
}

void HttpUploader::clear()
{
    if( mState == Done || mState == Opened || mState == Unsent ) {
        mState = Unsent;
        mUrl.clear();
        for(int i = 0 ; i < mPostFields.size() ; ++i)
            if(mPostFields[i] && !mPostFields[i]->mInstancedFromQml)
                delete mPostFields[i];
        mPostFields.clear();
        mProgress = 0;
        mStatus = 0;
        mErrorString.clear();
        mResponse.clear();
        emit stateChanged();
        emit urlChanged();
        emit progressChanged();
        emit statusChanged();
    }
}

void HttpUploader::open(const QUrl& url)
{
    if( mState == Unsent )
    {
        setUrl(url);
        mState = Opened;
        emit stateChanged();
    } else {
        qWarning() << "Invalid state of uploader" << mState << "to open";
    }
}

void HttpUploader::send()
{
    if( mState == Opened ) {
        QNetworkRequest request(mUrl);

        QCryptographicHash hash(QCryptographicHash::Sha1);
        foreach(QPointer<HttpPostField> field, mPostFields) {
            if( !field.isNull() ) {
                if(!field->validateVield()) {
                    mState = Done;
                    mErrorString = tr("Failed to validate POST fields");
                    mStatus = -1;
                    emit stateChanged();
                    emit statusChanged();
                    return;
                }
                hash.addData(field->name().toUtf8());
            }
        }

        mBoundaryString = "HttpUploaderBoundary" + hash.result().toHex();

        mUploadDevice = new HttpUploaderDevice(this);
        mUploadDevice->open(QIODevice::ReadOnly);

        request.setHeader(QNetworkRequest::ContentTypeHeader, ((HttpUploaderDevice *)mUploadDevice)->contentType);
        request.setHeader(QNetworkRequest::ContentLengthHeader, mUploadDevice->size());

        mPendingReply = mNetworkAccessManager->post(request, mUploadDevice);
        mState = Loading;
        mProgress = 0;

        connect(mPendingReply, SIGNAL(finished()), SLOT(reply_finished()));
        connect(mPendingReply, SIGNAL(uploadProgress(qint64,qint64)), SLOT(uploadProgress(qint64,qint64)));

        emit stateChanged();
        emit progressChanged();
    } else {
        qWarning() << "Invalid state of uploader" << mState << "to send";
    }
}

void HttpUploader::sendFile(const QString& fileName)
{
    if( mState == Opened ) {
        QNetworkRequest request(mUrl);

        mUploadDevice = new QFile(fileName, this);
        if(!mUploadDevice->open(QIODevice::ReadOnly)) {
            mState = Done;
            mErrorString = mUploadDevice->errorString();
            delete mUploadDevice;
            mUploadDevice = NULL;
            mStatus = -1;
            emit stateChanged();
            emit statusChanged();
            return;
        }

        mPendingReply = mNetworkAccessManager->post(request, mUploadDevice);
        mState = Loading;
        mProgress = 0;

        connect(mPendingReply, SIGNAL(finished()), SLOT(reply_finished()));
        connect(mPendingReply, SIGNAL(uploadProgress(qint64,qint64)), SLOT(uploadProgress(qint64,qint64)));

        emit stateChanged();
        emit progressChanged();
    } else {
        qWarning() << "Invalid state of uploader" << mState << "to send";
    }
}

void HttpUploader::abort()
{
    if( mState == Loading ) {
        mState = Aborting;
        emit stateChanged();
        mPendingReply->abort();
    }
}

void HttpUploader::addField(const QString& fieldName, const QString& fieldValue)
{
    HttpPostFieldValue * field = new HttpPostFieldValue(this);
    field->setName(fieldName);
    field->setValue(fieldValue);
    field->mInstancedFromQml = false;
    mPostFields.append(field);
}

void HttpUploader::addFile(const QString& fieldName, const QString& fileName, const QString& mimeType)
{
    HttpPostFieldFile * field = new HttpPostFieldFile(this);
    field->setName(fieldName);
    field->setSource(QUrl::fromLocalFile(fileName));
    field->setMimeType(mimeType);
    field->mInstancedFromQml = false;
    mPostFields.append(field);
}

void HttpUploader::reply_finished()
{
    mPendingReply->deleteLater();

    if( mPendingReply->error() == QNetworkReply::OperationCanceledError ) {
#ifdef QT_DEBUG
        qDebug() << "HttpUploader: Upload aborted";
#endif

        mPendingReply = NULL;
        delete mUploadDevice;
        mUploadDevice = NULL;
        mProgress = 0;
        mState = Done;
        mBoundaryString.clear();
        emit progressChanged();
        emit stateChanged();
        return;
    }

    mResponse = mPendingReply->readAll();

    if( mPendingReply->error() != QNetworkReply::NoError ) {
#ifdef QT_DEBUG
        qDebug() << "HttpUploader: Network error" << mPendingReply->error();
#endif

        delete mUploadDevice;
        mUploadDevice = NULL;
        mProgress = 0;
        mState = Done;
        mBoundaryString.clear();
        mErrorString = mPendingReply->errorString();
        mPendingReply = NULL;
        mStatus = 0;
        emit progressChanged();
        emit stateChanged();
        emit statusChanged();
        return;
    }

#ifdef QT_DEBUG
    qDebug() << "HttpUploader: Upload finished";
#endif

    delete mUploadDevice;
    mUploadDevice = NULL;
    mProgress = 1;
    mState = Done;
    mErrorString.clear();
    mPendingReply = NULL;
    mStatus = 200;

    emit progressChanged();
    emit statusChanged();
    emit stateChanged();
}

void HttpUploader::uploadProgress(qint64 bytesSent, qint64 bytesTotal)
{
    if( bytesTotal > 0 )
    {
        qreal progress = qreal(bytesSent) / qreal(bytesTotal);
        if(!qFuzzyCompare(progress, mProgress))
        {
            mProgress = progress;
#ifdef QT_DEBUG
            qDebug() << "HttpUploader: Progress is" << mProgress;
#endif
            emit progressChanged();
        }
    }
}

#include "httpuploader.moc"
