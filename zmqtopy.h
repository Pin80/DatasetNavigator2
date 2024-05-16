#ifndef ZMQTOPY_H
#define ZMQTOPY_H
#include <zmq.h>
#include <zmq.hpp>
#include <iostream>
#include <QObject>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtDebug>
#include <QFile>
#include <zhelpers.h>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QProcess>
#include <QFileInfo>
#include <QFuture>
#include <QtConcurrent/QtConcurrent>

class ZMQBackend: public QObject
{
    Q_OBJECT
public:
    ZMQBackend(QString _puburl, QString _suburl)
        : m_puburl(_puburl), m_suburl(_suburl)
    {
        m_isbound = false;
        m_context = zmq_ctx_new();
        if (!m_context)
        {
            qCritical() << "error in ZMQBackend (zmq_ctx_new)";
            m_isError = true;
        }
        m_future = QtConcurrent::run(this, &ZMQBackend::processZMQpool);
    }
    ~ZMQBackend()
    {
        terminateZMQ_pool();
    }
    ZMQBackend(const ZMQBackend &) = delete;
    ZMQBackend &operator=(const ZMQBackend &) = delete;

public slots:
    void onBindSocket()
    {
        if ((m_isError) || (m_isbound))
        {
            emit boundSocket(false);
            return;
        }
        m_lock.lock();
        if (m_bindTrigger)
        {
            emit boundSocket(false);
            m_lock.unlock();
            return;
        }
        m_bindTrigger = true;
        m_lock.unlock();
    }
    void onUnbindSocket()
    {
        if ((m_isError) || (!m_isbound))
        {
            emit unboundSocket(false);
            return;
        }
        m_lock.lock();
        if (m_unbindTrigger)
        {
            emit boundSocket(false);
            m_lock.unlock();
            return;
        }
        m_unbindTrigger = true;
        m_lock.unlock();
    }

    void onSendString(QString _fullstr)
    {
        if ((m_isError) || (!m_isbound))
        {
            emit sentString(false);
            return;
        }
        m_sentStr = _fullstr;
        m_lock.lock();
        if (m_sendTrigger)
        {
            emit boundSocket(false);
            m_lock.unlock();
            return;
        }
        m_sendTrigger = true;
        m_lock.unlock();
    }
    void terminateZMQ_pool()
    {
        if (m_isbound)
            stopZMQpool();
        m_isrunning = false;
        m_future.waitForFinished();
        int rc = zmq_ctx_destroy(m_context);
        if (rc != 0)
        {
            qCritical() << "error in terminateZMQ_pool (zmq_ctx_destroy)";
            m_isError = true;
        }
    }
public slots:
    void processFinished(int _code, QProcess::ExitStatus)
    {
        qWarning() << "Annotation window is closed";
        QCoreApplication::exit(_code);
    }
signals:
    void boundSocket(bool);
    void unboundSocket(bool);
    void sentString(bool);
    void recvString(QUrl);
private:
    QFuture<void> m_future;
    void * m_context = nullptr;
    void * m_publisher = nullptr;
    void * m_subscriber = nullptr;
    void * m_syncservice = nullptr;
    bool m_isbound = false;
    QString m_puburl;
    QString m_suburl;
    bool m_isrunning = false;
    char m_message[256];
    bool m_isError = false;
    bool m_bindTrigger = false;
    bool m_unbindTrigger = false;
    bool m_sendTrigger = false;
    QString m_sentStr;
    QMutex m_lock;
    void startZMQpool()
    {
        if (m_isError)
            return;
        bool result = false;
        if (m_isbound)
        {
            qCritical() << "error in startZMQpool";
            emit boundSocket(result);
            return;
        }

        //  Socket to talk to clients
        m_publisher = zmq_socket(m_context, ZMQ_PUB);
        if (!m_publisher)
        {
            qCritical() << "error in startZMQpool (pub):" << zmq_errno();
            m_isError = true;
            emit boundSocket(false);
            return;
        }
        m_subscriber = zmq_socket(m_context, ZMQ_SUB);
        if (!m_publisher)
        {
            qCritical() << "error in startZMQpool (sub):" << zmq_errno();
            m_isError = true;
            emit boundSocket(false);
            return;
        }
        int sndhwm = 256; // "tcp://127.0.0.1:5561"
        int rc = zmq_setsockopt (m_publisher, ZMQ_SNDHWM, &sndhwm, sizeof (int));
        if (rc != 0)
        {
            qCritical() << "error in startZMQpool (pub):" << zmq_errno();
            m_isError = true;
            emit boundSocket(false);
            return;
        }
        QString fullstr = m_puburl;
        const char * cutf8url = fullstr.toUtf8().data();
        m_isbound = (zmq_bind (m_publisher, cutf8url) == 0);
        if (m_isbound)
        {
            qInfo() << "socket bound on address:" << fullstr;
        }
        else
        {
            qCritical() << "error in startZMQpool (pub):" << zmq_errno();
            emit boundSocket(false);
            m_isError = true;
            return;
        }
        result = m_isbound;

        fullstr = m_suburl;
        cutf8url = fullstr.toUtf8().data();
        rc = zmq_connect(m_subscriber, cutf8url);
        if (rc != 0)
        {
            qCritical() << "error in startZMQpool (sub):" << zmq_errno();
            m_isError = true;
            return;
        }
        rc = zmq_setsockopt(m_subscriber, ZMQ_SUBSCRIBE, "", 0);
        if (rc != 0)
        {
            qCritical() << "error in startZMQpool (sub):" << zmq_errno();
            m_isError = true;
            return;
        }
        emit boundSocket(result);
        return;
    }
    void processZMQpool()
    {
        if (m_isError)
        {
            qCritical() << "error in processZMQpool";
            return;
        }
        m_isrunning = true;
        QString str;
        memset(m_message, 0, 256);
        while(m_isrunning)
        {
            if ((!m_isError) && (m_isbound))
            {
                int rc = zmq_recv(m_subscriber, m_message, 256, ZMQ_NOBLOCK);
                if (rc != -1)
                {
                    //EAGAIN
                    str = m_message;
                    str = "file:" + str;
                    qDebug() << "recvcpp:" << str;
                    memset(m_message, 0, 256);
                    emit recvString(QUrl(str));
                }
            }
            if ((!m_isError) && (!m_isbound) && (m_bindTrigger))
            {
                startZMQpool();
                m_lock.lock();
                m_bindTrigger = false;
                m_lock.unlock();
            }
            if ((!m_isError) && (m_isbound) && (m_unbindTrigger))
            {
                stopZMQpool();
                m_lock.lock();
                m_unbindTrigger = false;
                m_lock.unlock();
            }
            if ((!m_isError) && (m_isbound) && (m_sendTrigger))
            {

                int rc = s_send (m_publisher, m_sentStr.toUtf8().data());
                if (rc == -1)
                {
                    qCritical() << "error in processZMQpool (send):" << zmq_errno();
                    m_isError = true;
                    emit sentString(false);
                }
                else
                {
                    qInfo() << "send:" << m_sentStr.toUtf8().data();
                    emit sentString(true);
                }
                m_lock.lock();
                m_sendTrigger = false;
                m_lock.unlock();
            }
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
        }
    }
    void stopZMQpool()
    {
        bool result = false;
        if (!m_isbound)
        {
            emit unboundSocket(result);
            return;
        }
        int rc = 0;
        if (m_publisher)
            rc = zmq_close(m_publisher);
        if (rc != 0)
        {
            qCritical() << "error in stopZMQpool (zmq_close):" << zmq_errno();
        }
        m_publisher = nullptr;
        if (m_subscriber)
            rc = zmq_close(m_subscriber);
        if (rc != 0)
        {
            qCritical() << "error in stopZMQpool (zmq_close):" << zmq_errno();
        }
        m_subscriber = nullptr;
        m_isbound = false;
        result = !m_isbound;
        if (result)
            m_isError = false;
        emit unboundSocket(result);
        return;
    }
};


#endif // ZMQTOPY_H
