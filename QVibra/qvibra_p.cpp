#include "qvibra_p.h"
#include "qvibra.h"

QVibraPrivate::QVibraPrivate(QVibra *aPublicAPI) :
        iPublicQVibra(aPublicAPI),
        iStatus(QVibra::StatusOff)
{
    QObject::connect(&iTimer, SIGNAL(timeout()), iPublicQVibra, SLOT(stop()));
}

QVibraPrivate::~QVibraPrivate()
{
    delete iVibra;
}

QVibraPrivate* QVibraPrivate::NewL(QVibra *aPublicAPI)
{
    QVibraPrivate* self = new (ELeave) QVibraPrivate(aPublicAPI);
    CleanupStack::PushL(self);
    self->ConstructL();
    CleanupStack::Pop(self);
    return self;
}

void QVibraPrivate::ConstructL()
{
    TRAP(iError, this->iVibra = CHWRMVibra::NewL();)
}

void QVibraPrivate::VibraModeChanged(CHWRMVibra::TVibraModeState aStatus)
{
    /*
    EVibraModeUnknown   	 Not initialized yet or there is an error condion.
    EVibraModeON  	Vibration setting in the user profile is on.
    EVibraModeOFF  	Vibration setting in the user profile is off.
    */
}

void QVibraPrivate::VibraStatusChanged(CHWRMVibra::TVibraStatus aStatus)
{
    /*
    EVibraStatusUnknown   	 Vibra is not initialized yet or status is uncertain because of an error condition.
    EVibraStatusNotAllowed  	Vibra is set off in the user profile or some application is specifically blocking vibra.
    EVibraStatusStopped  	Vibra is stopped.
    EVibraStatusOn  	Vibra is on.
    */

    if (aStatus == CHWRMVibra::EVibraStatusUnknown ||
            aStatus == CHWRMVibra::EVibraStatusNotAllowed) {
        iStatus = QVibra::StatusNotAllowed;
        emit this->iPublicQVibra->statusChanged(iStatus);
    }

    if (iDuration ==  QVibra::InfiniteDuration) {
        if (iStatus != QVibra::StatusOff) {
            iStatus = QVibra::StatusOff;
            emit this->iPublicQVibra->statusChanged(iStatus);
        }
    }
}

bool QVibraPrivate::start(int duration, int intensity)
{
    //if( this->iVibra ) this->iVibra->StartVibraL(duration, intensity);
    if( this->iVibra ) {
       iDuration = duration;
       TRAP(iError,
            if (intensity == QVibra::DefaultIntensity) {
               iVibra->StartVibraL(QVibra::InfiniteDuration);
           } else {
               iVibra->StopVibraL();
               iVibra->StartVibraL(QVibra::InfiniteDuration, intensity);
           }

           if (duration != QVibra::InfiniteDuration) {
               iTimer.start(duration);
           } else {
               iTimer.stop();
           }

           if (iStatus != QVibra::StatusOn) {
               iStatus = QVibra::StatusOn;
               emit this->iPublicQVibra->statusChanged(iStatus);
           }
       )
       return (iError == KErrNone);
    }
}

bool QVibraPrivate::stop()
{
    if( this->iVibra ) this->iVibra->StopVibraL();
}

void QVibraPrivate::reserve()
{
    if( this->iVibra ) this->iVibra->ReserveVibraL();
}

void QVibraPrivate::release()
{
    if( this->iVibra ) this->iVibra->ReleaseVibra();
}

QVibra::Status QVibraPrivate::currentStatus() const
{
    if( iVibra->VibraStatus() == CHWRMVibra::EVibraStatusUnknown ||
        iVibra->VibraStatus() == CHWRMVibra::EVibraStatusNotAllowed) {
        return QVibra::StatusNotAllowed;
    }
    return iStatus;
}

QVibra::Error QVibraPrivate::error() const
{
    switch (iError) {
    case KErrNone:
        return QVibra::NoError;
    case KErrNoMemory:
        return QVibra::OutOfMemoryError;
    case KErrArgument:
        return QVibra::ArgumentError;
    case KErrInUse:
        return QVibra::VibraInUseError;
    case KErrGeneral:
        return QVibra::HardwareError;
    case KErrTimedOut:
        return QVibra::TimeOutError;
    case KErrLocked:
        return QVibra::VibraLockedError;
    case KErrAccessDenied:
        return QVibra::AccessDeniedError;
    default:
        return QVibra::UnknownError;
    }
}
