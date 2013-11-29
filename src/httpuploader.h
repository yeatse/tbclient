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

#ifndef HTTPUPLOADER_H
#define HTTPUPLOADER_H

#include <QtDeclarative>
#include <QtNetwork>

// Register the types below by calling, e.g.:
//
//    qmlRegisterUncreatableType<HttpPostField>("HttpUp", 1, 0, "HttpPostField", "Can't touch this");
//    qmlRegisterType<HttpPostFieldValue>("HttpUp", 1, 0, "HttpPostFieldValue");
//    qmlRegisterType<HttpPostFieldFile>("HttpUp", 1, 0, "HttpPostFieldFile");
//    qmlRegisterType<HttpUploader>("HttpUp", 1, 0, "HttpUploader");

class HttpUploader;

//! Base field for the HTTP uploader
//! This object is not instantiated directly, it rather acts as a base object for
//! all HTTP POST fields which can be added to the HttpUploader object.
class HttpPostField : public QObject
{
    Q_OBJECT
    Q_ENUMS(FieldType)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(FieldType type READ type CONSTANT FINAL)
    Q_PROPERTY(int contentLength READ contentLength NOTIFY contentLengthChanged)
public:
    //! Defines type of the HTTP POST field
    enum FieldType {
        FieldInvalid,       //!< Invalid field - not initialized
        FieldValue,         //!< Field is string
        FieldFile           //!< Filed is file
    };

    HttpPostField(QObject * parent = 0);
    virtual ~HttpPostField();

    //! Name of the field
    QString name() const;
    //! Sets name of the field
    void setName(const QString& name);

    //! HTTP POST field type
    HttpPostField::FieldType type() const;

    //! Return length of the content uploaded
    virtual int contentLength() = 0;

    //! Create QIODevice object which returns data to be uploaded
    virtual QIODevice * createIoDevice(QObject * parent = 0) = 0;

    //! Check if the field is valid (e.g. file exists)
    virtual bool validateVield() = 0;

signals:
    void nameChanged();
    void contentLengthChanged();

protected:
    //! Sets type of the field. Used only by derived classes
    void setType(HttpPostField::FieldType type);

protected:
    friend class HttpUploader;
    FieldType mType;
    QString mName;
    bool mInstancedFromQml;
};

QML_DECLARE_TYPE(HttpPostField)

//! UTF-8 encoded POST field
class HttpPostFieldValue : public HttpPostField
{
    Q_OBJECT
    Q_PROPERTY(QString value READ value WRITE setValue NOTIFY valueChanged)
public:
    HttpPostFieldValue(QObject * parent = 0);

    //! Return value as Unicode string
    QString value() const;
    //! Transform unicode string to UTF-8 buffer
    void setValue(const QString& value);

    virtual int contentLength();
    virtual QIODevice * createIoDevice(QObject * parent = 0);
    virtual bool validateVield();

signals:
    void valueChanged();

private:
    QByteArray mValue;
};

QML_DECLARE_TYPE(HttpPostFieldValue)

//! Raw file
class HttpPostFieldFile : public HttpPostField
{
    Q_OBJECT
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QString mimeType READ mimeType WRITE setMimeType NOTIFY mimeTypeChanged)
public:
    HttpPostFieldFile(QObject * parent = 0);

    virtual int contentLength();
    virtual QIODevice * createIoDevice(QObject * parent = 0);
    virtual bool validateVield();

    //! Source URL for the file
    QUrl source() const;
    //! Sets source URL of the file
    void setSource(const QUrl& url);

    //! Returns MIME type of the file
    QString mimeType() const;
    //! Sets MIME type of the file. If MIME type is empty, application/octet-stream is used by default
    void setMimeType(const QString& mime);

signals:
    void sourceChanged();
    void mimeTypeChanged();

private:
    QUrl mSource;
    QString mMime;
};

QML_DECLARE_TYPE(HttpPostFieldFile)

class HttpUploaderDevice;

//! The HTTP uploader objects. It works similar to the XMLHttpRequest object, but allows
//! uploading of the HTML form-like data.
class HttpUploader : public QObject, public QDeclarativeParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QDeclarativeParserStatus)
    Q_ENUMS(State)
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(QDeclarativeListProperty<HttpPostField> postFields READ postFields)
    Q_PROPERTY(qreal progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(State uploadState READ state NOTIFY stateChanged)
    Q_PROPERTY(int status READ status NOTIFY statusChanged)
    Q_PROPERTY(QString errorString READ errorString)
    Q_PROPERTY(QString responseText READ responseText)
    Q_CLASSINFO("DefaultProperty", "postFields")
public:
    //! State of the uploader object (compatible with XMLHttpRequest state)
    enum State {
        Unsent,     //!< Object is closed
        Opened,     //!< Object is open and ready to send
        Loading,    //!< Data is being sent
        Aborting,   //!< State entered when upload is being aborted
        Done        //!< Upload finished (you need to examine status property)
    };

    explicit HttpUploader(QObject *parent = 0);
    virtual ~HttpUploader();

    //! Get the destination URL
    QUrl url() const;
    //! Set the destination URL of the upload
    void setUrl(const QUrl& url);

    QDeclarativeListProperty<HttpPostField> postFields();
    qreal progress() const;
    HttpUploader::State state() const;
    QString errorString() const;
    QString responseText() const;
    int status() const;

public slots:
    //! Reset object to the initial state (close files/clear fields/etc.)
    void clear();
    //! Set object to the open state with specified URL
    void open(const QUrl& url);
    //! Start upload
    void send();
    //! Start upload, but use file as POST body
    void sendFile(const QString& fileName);
    //! Abort current transaction
    void abort();
    //! Add key/value field
    void addField(const QString& fieldName, const QString& fieldValue);
    //! Add file field
    void addFile(const QString& fieldName, const QString& fileName, const QString& mimeType = QString());

signals:
    void urlChanged();
    void progressChanged();
    void stateChanged();
    void statusChanged();

private:
    static void AppendFunction(QDeclarativeListProperty<HttpPostField> *, HttpPostField*);
    static int CountFunction(QDeclarativeListProperty<HttpPostField> *);
    static HttpPostField * AtFunction(QDeclarativeListProperty<HttpPostField> *, int);
    static void ClearFunction(QDeclarativeListProperty<HttpPostField> *);

private: // QDeclarativeParserStatus
    virtual void classBegin();
    virtual void componentComplete();

private slots:
    void reply_finished();
    void uploadProgress(qint64 bytesSent, qint64 bytesTotal);

private:
    bool mComplete;
    QNetworkAccessManager * mNetworkAccessManager;
    QUrl mUrl;
    QList< QPointer<HttpPostField> > mPostFields;
    qreal mProgress;
    State mState;
    QPointer<QNetworkReply> mPendingReply;
    QString mErrorString;
    QByteArray mBoundaryString;
    QIODevice * mUploadDevice;
    int mStatus;
    QByteArray mResponse;
    friend class HttpUploaderDevice;
};

#endif // HTTPUPLOADER_H
