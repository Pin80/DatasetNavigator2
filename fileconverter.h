#ifndef TCONVERTER_H
#define TCONVERTER_H
#include <iostream>
#include <QObject>
#include <QQmlApplicationEngine>
#include <QtDebug>
#include <QFile>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QFileInfo>
#include <QRegularExpression>
#include <broker.h>

class TConverter: public QObject
{
        Q_OBJECT
public:
    TConverter(TBroker* _broker);
signals:
    void converted(int);
public slots:
    void onStartConvert(QString _prefiz, QString _path);
    void onStartReindex(QString _prefiz, QString _path, int _start);
    void doconvert();
private:
    QString m_suffix;
    QString m_prefix;
    QString m_folder;
    TBroker* m_broker;
    QAtomicInt m_start = false;
    int m_startIdx;
    bool m_reindex = false;
};

#endif // TCONVERTER_H
