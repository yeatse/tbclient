CONFIG   += mobility
MOBILITY += contacts

INCLUDEPATH += ./QVibra

DEPENDPATH  += ./QVibra

HEADERS += qvibra.h qvibra_p.h
SOURCES += qvibra.cpp qvibra_p.cpp

# Allow network access on Symbian
#symbian:TARGET.CAPABILITY += SwEvent NetworkServices Location ReadUserData WriteUserData ReadDeviceData WriteDeviceData LocalServices UserEnvironment
# Allow Symbian Telephone API
#symbian:LIBS += -leuser -letel3rdparty -lcone -leikcore -lws32
symbian:LIBS += -lhwrmvibraclient
#symbian:LIBS += -llogsclient -llogcli -lefsrv
