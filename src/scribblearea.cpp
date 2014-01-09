#include "scribblearea.h"

#include <QPainter>
#include <QDir>
#include <QGraphicsSceneMouseEvent>

ScribbleArea::ScribbleArea(QDeclarativeItem *parent) :
    QDeclarativeItem(parent),
    mPenWidth(5),
    mModified(false)
{
    setFlag(QGraphicsItem::ItemHasNoContents, false);
    setAcceptedMouseButtons(Qt::LeftButton);
}

ScribbleArea::~ScribbleArea()
{
}

QColor ScribbleArea::color() const
{
    return mColor;
}

void ScribbleArea::setColor(const QColor &color)
{
    mColor = color;
    emit colorChanged();
}

qreal ScribbleArea::penWidth() const
{
    return mPenWidth;
}

void ScribbleArea::setPenWidth(const qreal &penWidth)
{
    mPenWidth = penWidth;
    emit penWidthChanged();
}

bool ScribbleArea::modified() const
{
    return mModified;
}

void ScribbleArea::setModified(const bool &modified)
{
    if (mModified != modified){
        mModified = modified;
        emit modifiedChanged();
    }
}

void ScribbleArea::clear()
{
    mImage.fill(qRgb(255, 255, 255));
    update();
    setModified(false);
}

bool ScribbleArea::save(const QString &fileName)
{
    QImage visibleImage(mImage);
    resizeImage(&visibleImage, boundingRect().size().toSize());

    QFileInfo info(fileName);
    QString path = info.absolutePath();
    QDir dir(path);
    if (!dir.exists()) dir.mkpath(dir.absolutePath());

    if (visibleImage.save(fileName)){
        setModified(false);
        return true;
    } else {
        return false;
    }
}

bool ScribbleArea::loadImage(const QString &fileName, int x, int y)
{
#ifdef QT_DEBUG
    qDebug() << fileName << x << y;
#endif
    QImage loadedImage;
    if (!loadedImage.load(fileName))
        return false;

    if (loadedImage.height() > boundingRect().height() || loadedImage.width() > boundingRect().width())
        loadedImage = loadedImage.scaled(boundingRect().size().toSize(), Qt::KeepAspectRatio);

    QPainter p(&mImage);
    p.drawImage(x, y, loadedImage);

    setModified(true);
    return true;
}

void ScribbleArea::mousePressEvent(QGraphicsSceneMouseEvent *event)
{
    if (this->isEnabled() && event->buttons() == Qt::LeftButton){
        lastPoint = event->pos();
        QPainter p(&mImage);
        QPen pen(QBrush(mColor), mPenWidth, Qt::SolidLine, Qt::RoundCap);
        p.setPen(pen);
        p.drawPoint(lastPoint);
        update(lastPoint.x() - mPenWidth,
               lastPoint.y() - mPenWidth,
               mPenWidth * 2,
               mPenWidth * 2);
    }
}

void ScribbleArea::mouseMoveEvent(QGraphicsSceneMouseEvent *event)
{
    if (this->isEnabled() && event->buttons() == Qt::LeftButton){
        endPoint = event->pos();
        drawLine();
    }
}

void ScribbleArea::mouseReleaseEvent(QGraphicsSceneMouseEvent *event)
{
    if (this->isEnabled() && event->buttons() == Qt::LeftButton){
        endPoint = event->pos();
        drawLine();
    }
}

void ScribbleArea::geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    Q_UNUSED(oldGeometry)
    if (newGeometry.width() > mImage.width() || newGeometry.height() > mImage.height())
        resizeImage(&mImage, QSize(newGeometry.width(), newGeometry.height()));
}

void ScribbleArea::paint(QPainter *painter, const QStyleOptionGraphicsItem *, QWidget *)
{
    painter->drawImage(boundingRect(), mImage, boundingRect());
}

void ScribbleArea::drawLine()
{
    QPainter p(&mImage);
    QPen pen(QBrush(mColor), mPenWidth, Qt::SolidLine, Qt::RoundCap);
    p.setPen(pen);
    p.drawLine(lastPoint, endPoint);
    update(qMin(lastPoint.x(), endPoint.x()) - mPenWidth,
           qMin(lastPoint.y(), endPoint.y()) - mPenWidth,
           qAbs(lastPoint.x() - endPoint.x()) + mPenWidth*2,
           qAbs(lastPoint.y() - endPoint.y()) + mPenWidth*2);
    lastPoint = endPoint;
}

void ScribbleArea::resizeImage(QImage *image, const QSize &newSize)
{
    if (image->size() == newSize)
        return;
    QImage newImage(newSize, QImage::Format_RGB32);
    newImage.fill(qRgb(255,255,255));
    QPainter p(&newImage);
    p.drawImage(QPoint(0, 0), *image);
    *image = newImage;
    update();
    setModified(true);
}

void ScribbleArea::componentComplete()
{
    QDeclarativeItem::componentComplete();
    mImage = QImage(boundingRect().size().toSize(), QImage::Format_RGB32);
    setModified(false);
}
