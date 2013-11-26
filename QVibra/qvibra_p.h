#ifndef QVIBRAPRIVATE_H
#define QVIBRAPRIVATE_H

#include <QTimer>
#include "qvibra.h"
#include <e32base.h>
#include <HWRMVibra.h> // Link against HWRMVibraClient.lib.

class QVibraPrivate : public CBase, public MHWRMVibraObserver
{
public:
    static QVibraPrivate* NewL(QVibra *aPublicAPI = 0);
    virtual ~QVibraPrivate();

public:
    bool start(int duration = QVibra::InfiniteDuration, int intensity=QVibra::MaxIntensity);
    bool stop();

    QVibra::Status currentStatus() const;
    QVibra::Error error() const;
    void reserve();
    void release();

private: // from MHWRMVibraObserver
    virtual void VibraModeChanged(CHWRMVibra::TVibraModeState aStatus);
    virtual void VibraStatusChanged(CHWRMVibra::TVibraStatus aStatus);


private:
    QVibraPrivate(QVibra *aPublicAPI);
    void ConstructL();
    CHWRMVibra* iVibra;
    QVibra* iPublicQVibra;
    QVibra::Status iStatus;
    QTimer iTimer;
    int iDuration;
    int iError;
};
#endif
