#ifndef TBROKER_H
#define TBROKER_H

#include <iostream>
#include <QObject>
#include <QtDebug>
#include <QFile>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QProcess>
#include <QFileInfo>
#include <QQuickView>
#include <QQmlComponent>
#include <QQmlContext>
#include <exception>
#include "zmqtopy.h"

// Нужен для взаимодействия между объектами, временем жизни которых управляет QML ,
// а также для хранения свойств и вызова бекенда из отдельного потока
class TBroker : public QObject
{
    Q_OBJECT
public:
    TBroker();
    ~TBroker();
    Q_PROPERTY(QString imgfolder READ getIFolder WRITE setIFolder NOTIFY ifldChanged)
    QString getIFolder() const
    {
        return m_ifolder;
    }
    void setIFolder(QString _fld)
    {
        m_ifolder = _fld;
    }
    QJsonObject& getSettings()
    {
        return m_jsonObj;
    }
signals:
    void ifldChanged(QString);
    void processTasks();
private:
    QString m_ifolder;
    QJsonObject m_jsonObj;
    QFuture<void> m_future;
    bool m_isrunning = false;
    void processBroker();
};


#endif // TBROKER_H
