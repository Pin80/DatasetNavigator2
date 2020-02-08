#ifndef TZMQIPC_H
#define TZMQIPC_H

#include <QObject>
#include <QQmlApplicationEngine>
#include <QQmlEngine>
#include <QtDebug>
#include <QFile>
#include <zmq.h>
#include <zmq.hpp>
#include <zhelpers.h>

class TZMQIPC : public QObject
{
    Q_OBJECT
    QString getMaskName(const QString& fname,
                        const QString& path,
                        const QString& prefix,
                        const QString& suffix)
    {
        QStringList nameparts = fname.split(suffix);
        if (nameparts.size() > 1)
        {
            QStringList partspath = path.split("file://");
            if (partspath.size() > 1)
            {
                QString newpath = partspath[1];
                QString newname = newpath + "/" + prefix + suffix + nameparts[1];
                bool result = QFile(newname).exists();
                //qDebug() << newname;
                //qDebug() << result;
                if (result)
                {
                    return newname;
                }
                return QString();
            }
            return QString();
        }
        return QString();
    }
    QString getshortMaskName(const QString& fname,
                             const QString& path,
                             const QString& prefix,
                             const QString& suffix)
    {
        QStringList nameparts = fname.split(suffix);
        if (nameparts.size() > 1)
        {
            QStringList partspath = path.split("file://");
            if (partspath.size() > 1)
            {
                QString newpath = partspath[1];
                QString newname = newpath + "/" + prefix + suffix + nameparts[1];
                bool result = QFile(newname).exists();
                //qDebug() << newname;
                //qDebug() << result;
                if (result)
                {
                    return prefix + suffix + nameparts[1];
                }
                return QString();
            }
            return QString();
        }
        return QString();
    }
public:
    static QObject * getInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
    {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        static TZMQIPC * pinstance = new TZMQIPC(nullptr);
        m_instance = pinstance;
        return pinstance;
    }
    Q_INVOKABLE bool bindSocket(const QString& urlstr)
    {
        //emit m_instance->boundSocket();
        //return true;
        qDebug() << urlstr;
        m_context = zmq_ctx_new ();

        //  Socket to talk to clients
        m_publisher = zmq_socket (m_context, ZMQ_PUB);

        int sndhwm = 256; // "tcp://127.0.0.1:5561"
        zmq_setsockopt (m_publisher, ZMQ_SNDHWM, &sndhwm, sizeof (int));
        QString fullstr = "tcp://" + urlstr;
        const char * cutf8url = fullstr.toUtf8().data();
        m_isbound = (zmq_bind (m_publisher, cutf8url) == 0);
        if (m_isbound)
        {
            emit m_instance->boundSocket();
        }
        return m_isbound;
    }
    Q_INVOKABLE bool unbindSocket(void)
    {
        //emit m_instance->unboundSocket();
        //return true;
        m_isbound = false;
        zmq_close (m_publisher);
        //zmq_close (m_syncservice);
        zmq_ctx_destroy (m_context);
        //  Get synchronization from subscribers
        //  printf ("Waiting for subscribers\n");
        emit m_instance->unboundSocket();
        return true;
    }

    Q_INVOKABLE bool sendString(const QString& fname,
                                const QString& path,
                                const QString& maskpath,
                                const QString& prefix,
                                const QString& suffix,
                                const bool foundMask)
    {
        //return true;
        if (m_isbound)
        {
            QString newpath = path;
            //  Now broadcast exactly 1M updates followed by END
            QStringList partspath = path.split("file://");
            if (partspath.size() > 1)
            {
                newpath = partspath[1];
            }
            QString maskname = "";
            if (foundMask)
            {
                maskname = getshortMaskName(fname, maskpath, prefix, suffix);
                qDebug() << "maskname" << maskname;
                //qDebug() << "fn" << fname;
            }
            QString fullname = newpath + "/" + fname + "*" + maskname;
            const char * tmpstr = fullname.toUtf8().data();
            s_send (m_publisher, tmpstr);
            qDebug() << fullname;
            return true;
        }
        else
        {
            return false;
        }
    }
    Q_INVOKABLE bool foundMaskName(const QString& fname,
                                   const QString& path,
                                   const QString& prefix,
                                   const QString& suffix)
    {
        return (getMaskName(fname, path, prefix, suffix) != QString());
    }
signals:
    void boundSocket();
    void unboundSocket();

private:
    static TZMQIPC * m_instance;
    void * m_context = nullptr;
    void * m_publisher = nullptr;
    void * m_syncservice = nullptr;
    bool m_isbound = false;
private:
    explicit TZMQIPC(QObject *parent = nullptr): QObject(parent) {}
    explicit TZMQIPC() = delete;
    explicit TZMQIPC(const TZMQIPC&) = delete;
    explicit TZMQIPC(const TZMQIPC&&) = delete;
};

#endif // TZMQIPC_H
