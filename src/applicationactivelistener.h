#ifndef APPLICATIONACTIVELISTENER_H
#define APPLICATIONACTIVELISTENER_H

#include <QObject>

class ApplicationActiveListener : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool active READ active NOTIFY activeChanged)

public:
    explicit ApplicationActiveListener(QObject *parent = 0);
    virtual ~ApplicationActiveListener();

    bool active() const;

protected:
    bool eventFilter(QObject *obj, QEvent *event);

signals:
    void activeChanged();

private:
    bool m_active;
};

#endif // APPLICATIONACTIVELISTENER_H
