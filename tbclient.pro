TEMPLATE = app
TARGET = tbclient

VERSION = 2.1.5
DEFINES += VER=\\\"$$VERSION\\\"

QT += network webkit
CONFIG += mobility
MOBILITY += location systeminfo multimedia

INCLUDEPATH += src

HEADERS += \
    src/utility.h \
    src/tbnetworkaccessmanagerfactory.h \
    src/downloader.h \
    src/httpuploader.h \
    src/audiorecorder.h \
    src/scribblearea.h \
    src/flickcharm.h \
    src/qwebviewitem.h \
    src/imageuploader.h

SOURCES += main.cpp \
    src/utility.cpp \
    src/tbnetworkaccessmanagerfactory.cpp \
    src/downloader.cpp \
    src/httpuploader.cpp \
    src/audiorecorder.cpp \
    src/scribblearea.cpp \
    src/flickcharm.cpp \
    src/qwebviewitem.cpp \
    src/imageuploader.cpp \
#    qml/tbclient/*.qml \
#    qml/tbclient/Browser/*.qml \
#    qml/tbclient/Component/*.qml \
#    qml/tbclient/Dialog/*.qml \
#    qml/tbclient/Explore/*.qml \
#    qml/tbclient/Floor/*.qml \
#    qml/tbclient/Forum/*.qml \
#    qml/tbclient/Message/*.qml \
#    qml/tbclient/Post/*.* \
#    qml/tbclient/Profile/*.qml \
#    qml/tbclient/Thread/*.qml \
#    qml/js/main.js \
#    qml/js/BaiduParser.js \
#    qml/js/LinkDecoder.js

TRANSLATIONS += i18n/tbclient_zh.ts
RESOURCES += tbclient-res.qrc

#qml folders
folder_symbian3.source = qml/tbclient
folder_symbian3.target = qml

folder_symbian1.source = qml/symbian1
folder_symbian1.target = qml

folder_harmattan.source = qml/harmattan
folder_harmattan.target = qml

folder_js.source = qml/js
folder_js.target = qml

folder_emo.source = qml/emo
folder_emo.target = qml

DEPLOYMENTFOLDERS = folder_js folder_emo

simulator {
    DEPLOYMENTFOLDERS += folder_symbian3 folder_symbian1 folder_harmattan
}

contains(MEEGO_EDITION,harmattan){
    DEFINES += Q_OS_HARMATTAN
    CONFIG += qdeclarative-boostable
    CONFIG += videosuiteinterface-maemo-meegotouch  #video suite
    CONFIG += meegotouch
    QT += dbus
    MOBILITY += gallery

    HEADERS += src/tbclientif.h \
        src/harmattanbackgroundprovider.h
    SOURCES += src/tbclientif.cpp \
        src/harmattanbackgroundprovider.cpp

    include(notifications/notifications.pri)

    splash.files = splash/splash.png
    splash.path = /opt/tbclient/splash
    INSTALLS += splash

    DEPLOYMENTFOLDERS += folder_harmattan
}

symbian {
#    contains(S60_VERSION, 5.0){
    contains(QT_VERSION, 4.7.3){
        DEFINES += Q_OS_S60V5
        INCLUDEPATH += $$[QT_INSTALL_PREFIX]/epoc32/include/middleware
        INCLUDEPATH += $$[QT_INSTALL_PREFIX]/include/Qt
        DEPLOYMENTFOLDERS += folder_symbian1
        MMP_RULES += "DEBUGGABLE"
    } else {
        CONFIG += qt-components
        MMP_RULES += "OPTION gcce -march=armv6 -mfpu=vfp -mfloat-abi=softfp -marm"
        DEPLOYMENTFOLDERS += folder_symbian3
    }

    CONFIG += localize_deployment

    TARGET.UID3 = 0x2006622A
    TARGET.CAPABILITY *= \
        NetworkServices \
        SwEvent \
        LocalServices \
        ReadUserData \
        WriteUserData \
        ReadDeviceData \
        WriteDeviceData \
        Location \
        UserEnvironment

    LIBS *= \
        -lMgFetch -lbafl \              #for Selecting Picture
        -lapparc -lws32 -lapgrfx \      #for Launching app
        -lServiceHandler -lnewservice \ #and -lbafl for Camera
        -lavkon \                       #for notification

    contains(DEFINES, Q_OS_S60V5){
        LIBS *= -laknnotify -leiksrv    #for global notes
        HEADERS += src/applicationactivelistener.h
        SOURCES += src/applicationactivelistener.cpp
        HEADERS -= src/qwebviewitem.h
        SOURCES -= src/qwebviewitem.cpp
    }

    DEFINES += QVIBRA

    TARGET.EPOCHEAPSIZE = 0x40000 0x4000000

    vendorinfo = "%{\"Yeatse\"}" ":\"Yeatse\""
    my_deployment.pkg_prerules += vendorinfo
    DEPLOYMENT += my_deployment

    # Symbian have a different syntax
    DEFINES -= VER=\\\"$$VERSION\\\"
    DEFINES += VER=\"$$VERSION\"
}

contains(DEFINES, QVIBRA): include(./QVibra/vibra.pri)

OTHER_FILES += \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/manifest.aegis \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()
