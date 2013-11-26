#include <QtGui/QApplication>
#include <QtDeclarative>
#include "qmlapplicationviewer.h"
#include "src/utility.h"
#include "src/tbnetworkaccessmanagerfactory.h"
#include "src/downloader.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    // Symbian specific
#ifdef Q_OS_SYMBIAN
    QApplication::setAttribute(Qt::AA_CaptureMultimediaKeys);
#endif
    QScopedPointer<QApplication> app(createApplication(argc, argv));

    app->setApplicationName("tbclient");
    app->setOrganizationName("Yeatse");
    app->setApplicationVersion(VER);

    // Install translator for qt
    QString locale = QLocale::system().name();
    QTranslator qtTranslator;
    if (qtTranslator.load("qt_"+locale, QLibraryInfo::location(QLibraryInfo::TranslationsPath)))
        app->installTranslator(&qtTranslator);
    QTranslator translator;
    if (translator.load(app->applicationName()+"_"+locale, ":/i18n/"))
        app->installTranslator(&translator);

    qmlRegisterType<Downloader>("com.yeatse.tbclient", 1, 0, "Downloader");

    QmlApplicationViewer viewer;
    viewer.setAttribute(Qt::WA_NoSystemBackground);

    TBNetworkAccessManagerFactory factory;
    viewer.engine()->setNetworkAccessManagerFactory(&factory);
    viewer.rootContext()->setContextProperty("utility", Utility::Instance());

    viewer.setMainQmlFile(QLatin1String("qml/tbclient/main.qml"));
    viewer.showExpanded();

    return app->exec();
}
