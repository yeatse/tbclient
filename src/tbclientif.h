#ifndef TBCLIENTIF_H
#define TBCLIENTIF_H

#include <QtDBus/QDBusAbstractAdaptor>
#include <QtGui/QApplication>
#include <QtDeclarative/QDeclarativeView>

class TBClientIf : public QDBusAbstractAdaptor
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.tbclient")

public:
    explicit TBClientIf(QApplication *app, QDeclarativeView *view);

public slots:
    void activateWindow();

private:
    QDeclarativeView *m_view;
};

#endif // TBCLIENTIF_H
