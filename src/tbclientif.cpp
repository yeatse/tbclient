#include "tbclientif.h"

TBClientIf::TBClientIf(QApplication *app, QDeclarativeView *view) :
    QDBusAbstractAdaptor(app),
    m_view(view)
{
}

void TBClientIf::activateWindow()
{
    m_view->activateWindow();
}
