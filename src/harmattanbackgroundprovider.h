#ifndef HARMATTANBACKGROUNDPROVIDER_H
#define HARMATTANBACKGROUNDPROVIDER_H

#include <QDeclarativeImageProvider>

class HarmattanBackgroundProvider : public QDeclarativeImageProvider
{
public:
    explicit HarmattanBackgroundProvider();
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
};

#endif // HARMATTANBACKGROUNDPROVIDER_H
