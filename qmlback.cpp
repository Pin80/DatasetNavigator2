#include "qmlback.h"

ColorImageProvider::ColorImageProvider(QObject * _main)
           : QQuickImageProvider(QQuickImageProvider::Pixmap),
             QObject(nullptr),
             m_main(_main)
{     }

QPixmap ColorImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
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
void ColorImageProvider::setRootElement(QObject * _main)
{
    m_main = _main;
}

void ColorImageProvider::onFolderName(QString _fld)
{
    auto url = QUrl::fromLocalFile(_fld);
    m_fld = url.toLocalFile();
    qDebug() << "onFolderName: new folder is" << m_fld;
}


TZMQIPC * TZMQIPC::getInstance(QQmlEngine *engine,
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

QString TZMQIPC::getSufText() const
{
    return m_suffix;
}

QUrl TZMQIPC::getFolder() const
{
    return QUrl::fromLocalFile(m_folder);
}

void TZMQIPC::setFolder(QUrl _fld)
{
    m_folder = _fld.toLocalFile();
    emit fldChanged(m_folder);
}

QUrl TZMQIPC::getMaskFolder() const
{
    return QUrl::fromLocalFile(m_maskfolder);
}

void TZMQIPC::setMaskFolder(QUrl _fld)
{
    m_maskfolder = _fld.toLocalFile();
    emit fldChanged(m_maskfolder);
}

void TZMQIPC::closeWindow()
{
    if (m_pyprocess->state() == QProcess::Running)
        m_pyprocess->terminate();
    m_pyprocess->waitForFinished();
}

bool TZMQIPC::sendString(const QString& fname,
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

bool TZMQIPC::foundMaskName(const QString& fname,
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

QString TZMQIPC::getMaskName(const QString& fname,
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

QUrl TZMQIPC::getshortMaskName(const QString& fname,
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


TZMQIPC::TZMQIPC(const QJsonObject& _jobj,
                 QProcess * _proc,
                 ZMQBackend* _zb,
                 ColorImageProvider* _cvp,
                 QObject *parent)
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
        value = m_jobj.value("start_folder");
        QString folder = value.toString();
        QString efolder = QDir::homePath() + "/" + folder;
        qWarning() << "efolder" << efolder;
        if (!QFileInfo::exists(efolder))
        {
            if (!QDir().mkpath(efolder))
            {
                qWarning() << "TZMQIPC constructor: start folder cannot be created:" << efolder;
            }
            else
            {
                m_folder = efolder;
                emit fldChanged(m_folder);
                value = m_jobj.value("mask_subfolder");
                QString mskfolder = efolder + "/" + value.toString();
                if (!QDir().mkpath(mskfolder))
                {
                    qWarning() << "TZMQIPC constructor: start mask folder cannot be created" << mskfolder;
                }
                else
                {
                    m_maskfolder = mskfolder;
                    emit mfldChanged(m_maskfolder);
                }

            }
        }
        else
        {
            m_folder = efolder;
            emit fldChanged(m_folder);
            value = m_jobj.value("mask_subfolder");
            m_maskfolder = efolder + "/" + value.toString();
            emit mfldChanged(m_maskfolder);
        }
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

TZMQIPC::~TZMQIPC()
{
    qDebug() << "Destructor called";
}




