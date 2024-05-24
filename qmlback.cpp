#include "qmlback.h"

ColorImageProvider::ColorImageProvider(TBroker *_broker)
           : QQuickImageProvider(QQuickImageProvider::Pixmap),
             QObject(nullptr),
             m_broker(_broker)
{
    connect(m_broker, SIGNAL(ifldChanged(QString)), this, SLOT(onFolderName(QString)));
}

QPixmap ColorImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
   const int cwidth = 325;
   const int cheight = 325;
   int width = cwidth;
   int height = cheight;
   QString sep = (m_fld.isEmpty())?"":"/";
   QString fullname = m_fld + sep + id;
   auto r_w = requestedSize.width();
   auto r_h = requestedSize.height();
   auto actual_w = r_w > 0 ? requestedSize.width() : width;
   auto actual_h = r_h > 0 ? requestedSize.height() : height;
   if (size)
      *size = QSize(actual_w, actual_h);
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

void ColorImageProvider::onFolderName(QString _fld)
{
    auto url = QUrl::fromLocalFile(_fld);
    m_fld = url.toLocalFile();
    qDebug() << "onFolderName: new folder is" << m_fld;
}


TZMQIPC * TZMQIPC::getInstance(QQmlEngine *engine,
                             QJSEngine *scriptEngine,
                             TBroker* _broker,
                             QProcess * _proc,
                             ZMQBackend* _zb,
                             TConverter* _cvt,
                             ColorImageProvider* _cvp)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    const QJsonDocument _jsonDoc;
    static TZMQIPC * pinstance = new TZMQIPC(_broker, _proc, _zb, _cvt, nullptr);
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
    //if (m_pyprocess->state() == QProcess::Running)
    //    m_pyprocess->terminate();
    //m_pyprocess->waitForFinished();
}

bool TZMQIPC::sendString(const QString& fname,
                            const QUrl& path,
                            const QUrl& maskpath,
                            const bool foundMask)
{
        QString newpath = path.toLocalFile();
        //  Now broadcast exactly 1M updates followed by END
        QString maskname = "";
        if (foundMask)
        {
            maskname = getMaskName(fname, maskpath.toString());
            //qDebug() << "fn" << fname;
        }
        QString fullname = newpath + "/" + fname + "*" + maskname;
        const char * tmpstr = fullname.toUtf8().data();
        emit sig_sendString(fullname);
        qDebug() << "send:" << fullname;
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

void TZMQIPC::convertFiles()
{
    emit sig_cvtFileNames();
}


TZMQIPC::TZMQIPC(TBroker* _broker,
                 QProcess * _proc,
                 ZMQBackend* _zb,
                 TConverter* _cvt,
                 QObject *parent)
    : QObject(parent), m_broker(_broker), m_pyprocess(_proc), m_zb(_zb), m_cvt(_cvt)
{
    try
    {
        qDebug() << "TZMQIPC constructor called";
        if (!m_broker)
            return;
        if (m_broker->getSettings().find("zmqurlpc") == m_broker->getSettings().end())
        {
            throw std::runtime_error("key is not found");
        }
        QJsonValue value = m_broker->getSettings().value("suffix");
        m_suffix = value.toString();
        value = m_broker->getSettings().value("mask_prefix");
        m_maskprefix = value.toString();
        emit sufChanged();
        value = m_broker->getSettings().value("start_folder");
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
                value = m_broker->getSettings().value("mask_subfolder");
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
            value = m_broker->getSettings().value("mask_subfolder");
            m_maskfolder = efolder + "/" + value.toString();
            emit mfldChanged(m_maskfolder);
        }
        if (m_zb)
        {
            connect(m_zb, SIGNAL(boundSocket(bool)), this, SIGNAL(boundSocket(bool)));
            connect(m_zb, SIGNAL(unboundSocket(bool)), this, SIGNAL(unboundSocket(bool)));
            connect(m_zb, SIGNAL(sentString(bool)), this, SIGNAL(sentString(bool)));
            connect(m_zb, SIGNAL(recvString(QUrl)), this, SIGNAL(recvString(QUrl)));
            connect(m_cvt, SIGNAL(converted(bool)), this, SIGNAL(converted(bool)));
            connect(this, SIGNAL(sig_bindSocket()), m_zb, SLOT(onBindSocket()));
            connect(this, SIGNAL(sig_unbindSocket()), m_zb, SLOT(onUnbindSocket()));
            connect(this, SIGNAL(sig_sendString(QString)), m_zb, SLOT(onSendString(QString)));
            connect(this, SIGNAL(sig_cvtFileNames()), m_cvt, SLOT(onStartConvert()));

        }
        QObject::connect(this, SIGNAL(fldChanged(QString)), m_broker, SIGNAL(ifldChanged(QString)));
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
    qDebug() << "TZMQIPC Destructor called";
}




