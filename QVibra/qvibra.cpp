#include "qvibra.h"
#include "qvibra_p.h"
#include <QDebug>

QVibra::QVibra(QObject *parent) : QObject(parent)
{
    QT_TRAP_THROWING(d = QVibraPrivate::NewL(this));
}

QVibra::~QVibra()
{
    delete d;
}

bool QVibra::start(int duration, int intensity)
{
    return ( this->d ) ? this->d->start(duration, intensity) : false;
}

bool QVibra::stop()
{
    return ( this->d ) ? this->d->stop() : false;
}

void QVibra::reserve()
{
    if( this->d ) this->d->reserve();
}

void QVibra::release()
{
    if( this->d ) this->d->release();
}

QVibra::Status QVibra::currentStatus() const
{
    return (this->d) ? d->currentStatus() : StatusNotAllowed;
}

QVibra::Error QVibra::error() const
{
    return (this->d) ? d->error() : NotCreated;
}

QString QVibra::errorString() const
{
    QString result = "";

    if (this->d) {
        switch(d->error()) {
        case QVibra::NoError          : result = "NoError";           break;
        case QVibra::OutOfMemoryError : result = "OutOfMemoryError";  break;
        case QVibra::ArgumentError    : result = "ArgumentError";     break;
        case QVibra::VibraInUseError  : result = "VibraInUseError";   break;
        case QVibra::HardwareError    : result = "HardwareError";     break;
        case QVibra::TimeOutError     : result = "TimeOutError";      break;
        case QVibra::VibraLockedError : result = "VibraLockedError";  break; // Vibra  is locked down because too much continuous use or explicitly blocked by for example some vibration sensitive accessory
        case QVibra::AccessDeniedError: result = "AccessDeniedError"; break;
        case QVibra::UnknownError     : result = "UnknownError";      break;
        //case QVibra::NotCreated       : result = "NotCreated";        break;
        default: result = "UnknownError"; break;
        }
    }
    return result;
}
