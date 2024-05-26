#ifndef ZMQTOPY_H
#define ZMQTOPY_H
#include <QObject>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtDebug>
#include <QFile>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QProcess>
#include <QFileInfo>
#include <QFuture>
#include <QtConcurrent/QtConcurrent>
#include <zmq.h>
#include <zmq.hpp>
#include <zhelpers.h>
#include <iostream>
#include <thread>
#include <errno.h>

class ZMQBackend: public QObject
{
    Q_OBJECT
public:
    ZMQBackend(QString _puburl, QString _suburl);
    ~ZMQBackend();
    ZMQBackend(const ZMQBackend &) = delete;
    ZMQBackend &operator=(const ZMQBackend &) = delete;
    bool isBound() const;
public slots:
    void onBindSocket();
    void onUnbindSocket();
    void onSendString(QString _fullstr);
    void terminateZMQ_pool();
public slots:
    void processFinished(int _code, QProcess::ExitStatus);
    void processZMQpool();
signals:
    void boundSocket(bool);
    void unboundSocket(bool);
    void sentString(bool);
    void recvString(QUrl);
private:
    void * m_context = nullptr;
    void * m_publisher = nullptr;
    void * m_subscriber = nullptr;
    void * m_syncservice = nullptr;
    bool m_isbound = false;
    QString m_puburl;
    QString m_suburl;
    char m_message[256];
    bool m_isError = false;
    bool m_bindTrigger = false;
    bool m_unbindTrigger = false;
    bool m_sendTrigger = false;
    QString m_sentStr;
    QMutex m_lock;
    void startZMQpool();
    void stopZMQpool();
};


#endif // ZMQTOPY_H
