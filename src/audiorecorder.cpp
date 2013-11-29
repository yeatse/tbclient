#include "audiorecorder.h"
#include <QAudioCaptureSource>

AudioRecorder::AudioRecorder(QObject *parent) :
    QObject(parent)
{
    captureSource = new QAudioCaptureSource;
    recorder = new QMediaRecorder(captureSource);
    audioSettings.setCodec("AMR");
    audioSettings.setQuality(QtMultimediaKit::HighQuality);
    recorder->setEncodingSettings(audioSettings);
    connect(recorder, SIGNAL(error(QMediaRecorder::Error)), this, SIGNAL(errorChanged()));
    connect(recorder, SIGNAL(stateChanged(QMediaRecorder::State)), this, SIGNAL(stateChanged()));
    connect(recorder, SIGNAL(durationChanged(qint64)), this, SIGNAL(durationChanged()));
}

AudioRecorder::~AudioRecorder()
{
    captureSource->deleteLater();
    recorder->deleteLater();
}

AudioRecorder::State AudioRecorder::state() const
{
    return static_cast<State>(recorder->state());
}

AudioRecorder::Error AudioRecorder::error() const
{
    return static_cast<Error>(recorder->error());
}

QUrl AudioRecorder::outputLocation() const
{
    return recorder->outputLocation();
}

int AudioRecorder::duration() const
{
    return recorder->duration();
}

void AudioRecorder::setOutputLocation(const QUrl &location)
{
    recorder->setOutputLocation(location);
    emit outputLocationChanged();
}

void AudioRecorder::record()
{
    recorder->record();
}

void AudioRecorder::stop()
{
    recorder->stop();
}
