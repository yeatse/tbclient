#include "applicationactivelistener.h"
#include <QtGui/QApplication>

ApplicationActiveListener::ApplicationActiveListener(QObject *parent) :
    QObject(parent),
    m_active(QApplication::activeWindow() != 0)
{
    if (qApp)
        qApp->installEventFilter(this);
}

ApplicationActiveListener::~ApplicationActiveListener()
{
}

bool ApplicationActiveListener::active() const
{
    return m_active;
}

bool ApplicationActiveListener::eventFilter(QObject *obj, QEvent *event)
{
    Q_UNUSED(obj)

    if (event->type() == QEvent::ApplicationActivate && !m_active){
        m_active = true;
        emit activeChanged();
    } else if (event->type() == QEvent::ApplicationDeactivate && m_active){
        m_active = false;
        emit activeChanged();
    }

    return false;
}
