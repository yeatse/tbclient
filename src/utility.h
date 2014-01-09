#ifndef UTILITY_H
#define UTILITY_H

#include <QtDeclarative>

class Utility : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString appVersion READ appVersion CONSTANT FINAL)
    Q_PROPERTY(int qtVersion READ qtVersion CONSTANT FINAL)
    Q_PROPERTY(QString imei READ imei CONSTANT FINAL)
    Q_PROPERTY(QString cachePath READ cachePath CONSTANT FINAL)
    Q_PROPERTY(QString tempPath READ tempPath CONSTANT FINAL)
    Q_PROPERTY(QString defaultPictureLocation READ defaultPictureLocation CONSTANT FINAL)

public:             // Not for qml
    static Utility* Instance();
    ~Utility();

    QString appVersion() const;
    int qtVersion() const;
    QString imei() const;
    QString cachePath() const;
    QString tempPath() const;
    QString defaultPictureLocation() const;

    void setEngine(QDeclarativeEngine* engine);

public:             // Cache and network
    // Save and load settings.
    Q_INVOKABLE QVariant getValue(const QString &key, const QVariant defaultValue = QVariant());
    Q_INVOKABLE void setValue(const QString &key, const QVariant &value);

    // Save and load user data.
    Q_INVOKABLE void setUserData(const QString &key, const QString &data);
    Q_INVOKABLE QString getUserData(const QString &key);
    Q_INVOKABLE bool clearUserData();

    // Clear network cookies.
    Q_INVOKABLE void clearCookies() const;

    // Save network cache.
    Q_INVOKABLE bool saveCache(const QString &remoteUrl, const QString &localPath);
    // Return network cache as bytes.
    Q_INVOKABLE int cacheSize();
    // Clear network cache.
    Q_INVOKABLE void clearCache();
    // Get current network bearer
    Q_INVOKABLE QString currentBearerName();

public:             // Symbian avkon helper.
    // Launch web browser
    Q_INVOKABLE void openURLDefault(const QString &url);

    // Launch player
    Q_INVOKABLE void launchPlayer(const QString &url);

    // Symbian: 0 ---- library, 1 ---- folder, 2 ---- camera, 3 ---- multiple images
    // Else: just from folder
    // Return empty string if canceled.
    Q_INVOKABLE QString selectImage(int param = 0);

    // Return empty string if canceled
    Q_INVOKABLE QString selectFolder();

    // Select color
    // Return defaultColor if canceled
    Q_INVOKABLE QColor selectColor(const QColor &defaultColor);

    // Show notification
    Q_INVOKABLE void showNotification(const QString &title, const QString &message) const;

#ifdef Q_OS_SYMBIAN
    void LaunchL(int id, const QString& param);
#endif

public:             // Other functions.
    Q_INVOKABLE bool existsFile(const QString &filename);
    Q_INVOKABLE int fileSize(const QString &filename);
    Q_INVOKABLE QString fileHash(const QString &filename);
    Q_INVOKABLE QString chunkFile(const QString &filename, int pos, int length = 30720);
    Q_INVOKABLE void copyToClipbord(const QString &text);
    Q_INVOKABLE QString cutImage(const QString &filename, double scale, int x, int y, int width, int height);

    // Make date readable
    Q_INVOKABLE QString easyDate(const QDateTime &date);

    // Restore GBK encoded data
    Q_INVOKABLE QString decodeGBKHex(const QString &encodedString);

    // Percent decoding
    Q_INVOKABLE QString percentDecode(const QByteArray &encodedString) const;

private:
    explicit Utility(QObject *parent = 0);    
    void initializeLangFormats();
    int normalize(int val, int single);
    bool deleteDir(const QString &dirName);

#ifdef Q_OS_SYMBIAN
    void LaunchAppL(const TUid aUid, HBufC* aParam);
    // Reture empty string if canceled;
    // Otherwise return captured image url;
    QString CaptureImage();
    // Return empty string if canceled;
    // Otherwise return selected image url;
    QString LaunchLibrary();
    QString LaunchLibrary2();
#endif

private:
    QPointer<QSettings> settings;
    QPointer<QDeclarativeEngine> engine;
    QVariantMap map;
    QHash<QString, QString> lang;
    QList<QVariantList> formats;
};

#endif // UTILITY_H
