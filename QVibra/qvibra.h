#ifndef QVIBRA_H
#define QVIBRA_H

#include <QObject>

class QVibraPrivate;

class QVibra : public QObject
{
    Q_OBJECT
    Q_DECLARE_PRIVATE(QVibra)
    Q_ENUMS(Status)
    Q_ENUMS(Error)
    Q_CLASSINFO("Author", "Sebastiano Galazzo")
    Q_CLASSINFO("Email", "sebastiano.galazzo@gmail.com")

public:
    QVibra(QObject *parent = 0);
    virtual ~QVibra();

    static const int InfiniteDuration =  0;
    static const int MaxIntensity     =  100;
    static const int DefaultIntensity =  100;
    static const int MinIntensity     = -100;

    enum Error {
       NoError = 0,
       OutOfMemoryError,
       ArgumentError,
       VibraInUseError,
       HardwareError,
       TimeOutError,
       VibraLockedError,
       AccessDeniedError,
       UnknownError = -1,
       NotCreated
    };

    enum Status {
       StatusNotAllowed = 0,
       StatusOff,
       StatusOn
    };

    QVibra::Status currentStatus() const;
    QVibra::Error error() const;
    Q_INVOKABLE QString errorString() const;

signals:
    void statusChanged(QVibra::Status status);

public slots:
    /**
     * @brief Start vibration
     * @param duration, 	Duration of the vibration measured in milliseconds. A value of InfiniteDuration specifies that the vibration should continue indefinetely and should be stopped with a call to stop. Duration usually has device specific maximum value
     * @param intensity,	Intensity of the vibra in decimal is MinIntensity to MaxIntensity, which shows the percentage of the vibra motor full rotation speed. When intensity is negative, the vibra motor rotates in the negative direction. When intensity is positive, the vibra motor rotates in the positive direction. Value 0 stops the vibra. NOTE: The device might have hardware-imposed limits on supported vibra intensity values, so actual effect might vary between different hardware.
     */
    bool start(int duration = InfiniteDuration, int intensity=MaxIntensity);
    bool stop();
    void reserve();
    void release();

private:
    QVibraPrivate *d;  //pointer to implementation

private:    // Friend class definitions
    friend class QVibraPrivate;

};
#endif


