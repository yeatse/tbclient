#include "harmattanbackgroundprovider.h"
#include <QPainter>

HarmattanBackgroundProvider::HarmattanBackgroundProvider()
    : QDeclarativeImageProvider(QDeclarativeImageProvider::Image)
{
}

QImage HarmattanBackgroundProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    Q_UNUSED(requestedSize)
    QImage result;

    bool inverted = id.endsWith("-inverted");
    QString filename = inverted ? id.left(id.size()-9) : id;

    if (result.load(filename)){
        result = result.scaled(QSize(480, 854), Qt::KeepAspectRatioByExpanding);
        result = result.copy(0, 0, 480, 854);
        QPainter p(&result);
        QColor c = inverted ? QColor(0, 0, 0, 108) : QColor(224, 225, 226, 80);
        p.fillRect(result.rect(), c);
    }

    size->setWidth(result.width());
    size->setHeight(result.height());

    return result;
}
