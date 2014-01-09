#ifndef SCRIBBLEAREA_H
#define SCRIBBLEAREA_H

#include <QDeclarativeItem>

class QGraphicsSceneMouseEvent;

class ScribbleArea : public QDeclarativeItem
{
    Q_OBJECT
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(qreal penWidth READ penWidth WRITE setPenWidth NOTIFY penWidthChanged)
    Q_PROPERTY(bool modified READ modified NOTIFY modifiedChanged)

public:
    explicit ScribbleArea(QDeclarativeItem *parent = 0);
    ~ScribbleArea();

    QColor color() const;
    void setColor(const QColor &color);

    qreal penWidth() const;
    void setPenWidth(const qreal &penWidth);

    bool modified() const;
    void setModified(const bool &modified);

public:
    Q_INVOKABLE void clear();
    Q_INVOKABLE bool save(const QString &fileName);
    Q_INVOKABLE bool loadImage(const QString &fileName, int x=0, int y=0);

signals:
    void colorChanged();
    void penWidthChanged();
    void modifiedChanged();

protected:
    void mousePressEvent(QGraphicsSceneMouseEvent *event);
    void mouseMoveEvent(QGraphicsSceneMouseEvent *event);
    void mouseReleaseEvent(QGraphicsSceneMouseEvent *event);
    void geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry);
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *, QWidget *);

private:
    void drawLine();
    void resizeImage(QImage *image, const QSize &newSize);

private:
    virtual void componentComplete();

private:
    QColor mColor;
    qreal mPenWidth;
    bool mModified;

    QImage mImage;
    QPointF lastPoint, endPoint;
};

#endif // SCRIBBLEAREA_H
