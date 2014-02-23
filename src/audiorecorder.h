#ifndef AUDIORECORDER_H
#define AUDIORECORDER_H

#include <QObject>
#include <QMediaRecorder>
#include <QAudioCaptureSource>
#include <QPointer>
#include <QUrl>

class AudioRecorder : public QObject
{
    Q_OBJECT
    Q_ENUMS(Error)
    Q_ENUMS(State)
    Q_PROPERTY(Error error READ error NOTIFY errorChanged)
    Q_PROPERTY(State state READ state NOTIFY stateChanged)
    Q_PROPERTY(int duration READ duration NOTIFY durationChanged)
    Q_PROPERTY(QUrl outputLocation READ outputLocation WRITE setOutputLocation NOTIFY outputLocationChanged)

public:
    enum Error {
        NoError = QMediaRecorder::NoError,
        ResourceError = QMediaRecorder::ResourceError,
        FormatError = QMediaRecorder::FormatError
    };
    enum State {
        StoppedState = QMediaRecorder::StoppedState,
        RecordingState = QMediaRecorder::RecordingState,
        PausedState = QMediaRecorder::PausedState
    };

    explicit AudioRecorder(QObject *parent = 0);
    ~AudioRecorder();

    State state() const;
    Error error() const;
    QUrl outputLocation() const;
    void setOutputLocation(const QUrl &location);
    int duration() const;

    Q_INVOKABLE void record();
    Q_INVOKABLE void stop();

signals:
    void stateChanged();
    void errorChanged();
    void outputLocationChanged();
    void durationChanged();

private:
    QPointer<QAudioCaptureSource> captureSource;
    QPointer<QMediaRecorder> recorder;
    QAudioEncoderSettings audioSettings;
};

#endif // AUDIORECORDER_H
