#ifndef QMLBACK_H
#define QMLBACK_H

#include <iostream>
#include <QObject>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlEngine>
#include <QtDebug>
#include <QFile>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QProcess>
#include <QPixmap>
#include <QQuickImageProvider>
#include <QFileInfo>
#include "zmqtopy.h"

class ColorImageProvider : public QObject, public QQuickImageProvider
{
    Q_OBJECT
public:
    ColorImageProvider(QObject * _main = nullptr)
               : QQuickImageProvider(QQuickImageProvider::Pixmap),
                 QObject(nullptr),
                 m_main(_main)
    {     }

    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize) override
    {
       const int cwidth = 125;
       const int cheight = 125;
       int width = cwidth;
       int height = cheight;
       if (m_main)
       {
           QVariant varvalue = m_main->property("imgwidth");
           if ((!varvalue.isValid()) || (varvalue.type() != QVariant::Int))
           {
               //error
                width = cwidth;
           }
           else
           {
                width = varvalue.toInt()*0.9;
           }
           varvalue = m_main->property("imgheight");
           if ((!varvalue.isValid()) || (varvalue.type() != QVariant::Int))
           {
               //error
               height = cheight;
           }
           else
           {
                height = varvalue.toInt()*0.9;
           }
       }
       else
       {
           width = cwidth;
           height = cheight;
       }
       QString sep = (m_fld.isEmpty())?"":"/";
       QString fullname = m_fld + sep + id;
       if (size)
          *size = QSize(width, height);
       auto r_w = requestedSize.width();
       auto r_h = requestedSize.height();
       auto actual_w = r_w > 0 ? requestedSize.width() : width;
       auto actual_h = r_h > 0 ? requestedSize.height() : height;
       if (QFileInfo::exists(fullname))
       {
           QPixmap pixmap(fullname);
           auto spixmap = pixmap.scaled(actual_w, actual_h, Qt::KeepAspectRatio);
           return spixmap;
       }
       else
       {
           QPixmap pixmap(actual_w, actual_h);
           pixmap.fill(QColor("red").rgba());
           return pixmap;
       }
    }
    void setRootElement(QObject * _main)
    {
        m_main = _main;
    }
private:
    QString m_fld;
    QObject * m_main = nullptr;
public slots:
    void onFolderName(QString _fld)
    {
        auto url = QUrl(_fld);
        m_fld = url.toLocalFile();
        qDebug() << "onFolderName: new folder is" << m_fld;
    }
};


//QObject has neither a copy constructor nor an assignment operator.
class TZMQIPC : public QObject
{
    Q_OBJECT
public:
    static int typeId;
    static TZMQIPC * getInstance(QQmlEngine *engine,
                                 QJSEngine *scriptEngine,
                                 const QJsonObject& _jobj,
                                 QProcess * _proc,
                                 ZMQBackend* _zb,
                                 ColorImageProvider* _cvp)
    {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        const QJsonDocument _jsonDoc;
        static TZMQIPC * pinstance = new TZMQIPC(_jobj, _proc, _zb, _cvp, nullptr);
        //m_instance = pinstance;
        return pinstance;
    }
    Q_PROPERTY(QString jsuffix READ getSufText NOTIFY sufChanged);
    QString getSufText() const
    {
        return m_suffix;
    }

    Q_PROPERTY(QString folder READ getFolder WRITE setFolder NOTIFY fldChanged);
    QString getFolder() const
    {
        return m_folder;
    }
    void setFolder(QString _fld)
    {
        m_folder = _fld;
        emit fldChanged(m_folder);
    }
    Q_PROPERTY(QString maskfolder READ getMaskFolder WRITE setMaskFolder NOTIFY mfldChanged);
    QString getMaskFolder() const
    {
        return m_folder;
    }
    void setMaskFolder(QString _fld)
    {
        m_folder = _fld;
        emit fldChanged(m_folder);
    }
    Q_INVOKABLE void closeWindow()
    {
        if (m_pyprocess->state() == QProcess::Running)
            m_pyprocess->terminate();
        m_pyprocess->waitForFinished();
    }

    Q_INVOKABLE bool sendString(const QString& fname,
                                const QString& path,
                                const QString& maskpath,
                                const bool foundMask)
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
                maskname = getMaskName(fname, maskpath);
                //qDebug() << "fn" << fname;
            }
            QString fullname = newpath + "/" + fname + "*" + maskname;
            const char * tmpstr = fullname.toUtf8().data();
            emit sig_sendString(fullname);
            qDebug() << "send:" << fullname << " with maskname: " << maskname;
            return true;
    }
    Q_INVOKABLE bool foundMaskName(const QString& fname,
                                   const QString& path)
    {
        auto teststr = getMaskName(fname, path);
        if (teststr.isEmpty())
        {
            return false;
        }
        if (QFileInfo::exists(teststr))
        {
            return true;
        }
        return false;
    }
    Q_INVOKABLE QString getMaskName(const QString& fname,
                                    const QString& path)
    {
        if (path.isEmpty())
        {
            return QString();
        }
        QStringList nameparts = fname.split(m_suffix);
        if (nameparts.size() <= 1)
        {
            return QString();
        }
        QUrl urlpath = QUrl(path);
        QString lpath = urlpath.toLocalFile();
        if (!lpath.isEmpty())
        {
            QString newpath = lpath;
            QString newname = newpath + "/" + m_maskprefix + m_suffix + nameparts[1];
            return newname;
        }
        return QString();
    }
    Q_INVOKABLE QUrl getshortMaskName(const QString& fname,
                                         const QString& path)
    {
        QStringList nameparts = fname.split(m_suffix);
        if (nameparts.size() > 1)
        {
            QUrl urlpath = QUrl(path);
            QString lpath = urlpath.toLocalFile();
            if (!lpath.isEmpty())
            {
                QString newpath = lpath;
                QString newname = newpath + "/" + m_maskprefix + m_suffix + nameparts[1];
                //qDebug() << newname;
                //qDebug() << result;
                return QUrl("file:" + m_maskprefix + m_suffix + nameparts[1]);
            }
            return QString();
        }
        return QString();
    }
signals:
    void sig_bindSocket();
    void sig_unbindSocket();
    void sig_sendString(QString);
    void boundSocket(bool result);
    void unboundSocket(bool result);
    void sentString(bool result);
    void recvString(QUrl result);
    void urlChanged();
    void sufChanged();
    void folderSet(QString);
    void fldChanged(QString);
    void mfldChanged(QString);
    void pypChanged(QProcess *);
private:
    const QJsonObject m_jobj;
    QString m_suffix;
    QString m_maskprefix;
    QString m_folder;
    QString m_maskfolder;
    QProcess * m_pyprocess = nullptr;
    ZMQBackend* m_zb = nullptr;
    ColorImageProvider* m_cvp = nullptr;
    explicit TZMQIPC(const QJsonObject& _jobj,
                     QProcess * _proc,
                     ZMQBackend* _zb,
                     ColorImageProvider* _cvp,
                     QObject *parent = nullptr)
        : QObject(parent), m_jobj(_jobj), m_pyprocess(_proc), m_zb(_zb), m_cvp(_cvp)
    {
        try
        {
            qDebug() << "TZMQIPC constructor called";
            if (m_jobj.find("zmqurlpc") == m_jobj.end())
            {
                throw std::runtime_error("key is not found");
            }

            QJsonValue value = m_jobj.value("suffix");
            m_suffix = value.toString();
            value = m_jobj.value("mask_prefix");
            m_maskprefix = value.toString();
            emit sufChanged();
            if (m_zb)
            {
                connect(m_zb, SIGNAL(boundSocket(bool)), this, SIGNAL(boundSocket(bool)));
                connect(m_zb, SIGNAL(unboundSocket(bool)), this, SIGNAL(unboundSocket(bool)));
                connect(m_zb, SIGNAL(sentString(bool)), this, SIGNAL(sentString(bool)));
                connect(m_zb, SIGNAL(recvString(QUrl)), this, SIGNAL(recvString(QUrl)));
                connect(this, SIGNAL(sig_bindSocket()), m_zb, SLOT(onBindSocket()));
                connect(this, SIGNAL(sig_unbindSocket()), m_zb, SLOT(onUnbindSocket()));
                connect(this, SIGNAL(sig_sendString(QString)), m_zb, SLOT(onSendString(QString)));
            }
            if (m_cvp)
            {
                QObject::connect(this,SIGNAL(fldChanged(QString)),m_cvp,SLOT(onFolderName(QString)));
            }
        }
        catch (const std::runtime_error& _err)
        {
            qCritical()  << "error: " << _err.what() << " in TZMQIPC";
            qmlEngine(this)->throwError(tr("Error"));
        }
        catch (...)
        {
            qCritical()  << "unknown error in TZMQIPC";
        }
    }
    ~TZMQIPC()
    {
        qDebug() << "Destructor called";
    }
    explicit TZMQIPC() = delete;
    explicit TZMQIPC(const TZMQIPC&) = delete;
    explicit TZMQIPC(const TZMQIPC&&) = delete;
};


bool init(QQmlApplicationEngine& _engine);

struct TInit
{
    QJsonObject jsonObj;
    QScopedPointer<ColorImageProvider> prov;
    QScopedPointer< QProcess > pyprocess;
    QScopedPointer<ZMQBackend> zbackend;
};

extern TInit initstruct;
#endif // QMLBACK_H
