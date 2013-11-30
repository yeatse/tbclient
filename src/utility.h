#ifndef UTILITY_H
#define UTILITY_H

#include <QtDeclarative>

class Utility : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString appVersion READ appVersion CONSTANT)
    Q_PROPERTY(int qtVersion READ qtVersion CONSTANT)
    Q_PROPERTY(QString imei READ imei CONSTANT)
    Q_PROPERTY(QString cachePath READ cachePath CONSTANT)
    Q_PROPERTY(QString tempPath READ tempPath CONSTANT)

public:             // Properties
    static Utility* Instance();
    ~Utility();
    QString appVersion() const;
    int qtVersion() const;
    QString imei() const;
    QString cachePath() const;
    QString tempPath() const;

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

public:             // Other functions.
    Q_INVOKABLE bool existsFile(const QString &filename);
    Q_INVOKABLE int fileSize(const QString &filename);
    Q_INVOKABLE QString fileHash(const QString &filename);
    Q_INVOKABLE QString chunkFile(const QString &filename, int pos, int length = 30720);
    Q_INVOKABLE void copyToClipbord(const QString &text);

    // Make date readable
    Q_INVOKABLE QString easyDate(const QDateTime &date);

    // Restore GBK encoded data
    Q_INVOKABLE QString decodeGBKHex(const QString &encodedString);

private:
    explicit Utility(QObject *parent = 0);
    QPointer<QSettings> settings;
    QPointer<QDeclarativeEngine> engine;
    QVariantMap map;
    QHash<QString, QString> lang;
    QList<QVariantList> formats;

    void initializeLangFormats();
    int normalize(int val, int single);
    bool deleteDir(const QString &dirName);

#ifdef Q_OS_SYMBIAN
    void LaunchAppL(const TUid aUid, HBufC* aParam);
    void LaunchL(int id, const QString& param);
    // Reture empty string if canceled;
    // Otherwise return captured image url;
    QString CaptureImage();
    // Return empty string if canceled;
    // Otherwise return selected image url;
    QString LaunchLibrary();
    QString LaunchLibrary2();
#endif
};

#endif // UTILITY_H
