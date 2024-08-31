#include "init.h"
#ifdef Q_OS_LINUX
#include <sys/sysinfo.h>
#endif

QScopedPointer<QFile>   m_logFile;
TInit initstruct;

void messageHandler(QtMsgType type,
                    const QMessageLogContext &context,
                    const QString &msg)
{
    // Открываем поток записи в файл
    QTextStream out(m_logFile.data());
    // Записываем дату записи
    out << QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss.zzz ");
    // По типу определяем, к какому уровню относится сообщение
    QString fullstr;
    switch (type)
    {
    case QtInfoMsg:     fullstr =  "INF "; break;
    case QtDebugMsg:    fullstr =  "DBG "; break;
    case QtWarningMsg:  fullstr =  "WRN "; break;
    case QtCriticalMsg: fullstr =  "CRT "; break;
    case QtFatalMsg:    fullstr =  "FTL "; break;
    }
    // Записываем в вывод категорию сообщения и само сообщение
    fullstr = QString(context.category) + ": " + msg;
    out << fullstr << endl;
    out.flush();    // Очищаем буферизированные данные
    if ((type == QtCriticalMsg) || (type == QtFatalMsg))
    {
        QErrorMessage msgDialog;
        msgDialog.showMessage(msg);
        msgDialog.exec();
    }
}

QObject* getInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    TZMQIPC * inst = TZMQIPC::getInstance(engine,
                                          scriptEngine,
                                          initstruct.broker.get(),
                                          initstruct.pyprocess.get(),
                                          initstruct.zbackend.get(),
                                          initstruct.fbackend.get(),
                                          initstruct.prov.get());
    return inst;
}

bool log_process()
{
    const char * logfname = "datasetnavigator.log";
    QFileInfo logInfo;
    logInfo.setFile(logfname);
    // simple log rotation
    if (logInfo.exists())
    {
        QDir directory("");
        QDateTime current = QDateTime::currentDateTime();
        QDateTime created = logInfo.created();
        int days = created.daysTo(current);
        if (days > 0)
        {
            QStringList logs = directory.entryList(QStringList() << "*.log" ,QDir::Files);
            foreach(QString filename, logs)
            {
                if ((filename.contains(logfname)) && (filename.size() > QString(logfname).size()))
                {
                    directory.remove(filename);
                }
            }
            QString newname = logInfo.baseName() + "_" + created.toString("dd.MM.yyyy") + "." + logInfo.completeSuffix();
            QFile::rename(logfname, newname);
        }
    }
    m_logFile.reset(new QFile(logfname));
    m_logFile.data()->open(QFile::Append | QFile::Text);
    return (m_logFile->isOpen());
}

bool init(QQmlApplicationEngine& _engine, const QUrl _url)
{

    QJsonValue value = initstruct.broker->getSettings().value("zmqurlpc");
    QString urlpc = value.toString();
    if (urlpc.isEmpty())
    {
        qCritical() << "No annot tool to DN url is found in settings.json";
        return false;
    }
    value = initstruct.broker->getSettings().value("zmqurlcp");
    QString urlcp = value.toString();
    if (urlcp.isEmpty())
    {
        qCritical() << "No DN to annot tool url is found in settings.json";
        return false;
    }

    value = initstruct.broker->getSettings().value("python_app");
    QString pyapp = value.toString();
    initstruct.pyprocess.reset( new QProcess(nullptr));
    QString program = "python3";
    QString scriptFile =  pyapp;
    QStringList pythonCommandArguments = QStringList() << scriptFile;
    #ifndef QT_DEBUG
    initstruct.pyprocess->start(program, pythonCommandArguments);
    initstruct.pyprocess->waitForStarted(1000);
    if (initstruct.pyprocess->state() != QProcess::ProcessState::Running)
    {
        qCritical() << "Python application is not found";
        return false;
    }
    #endif

    initstruct.zbackend.reset(new ZMQBackend(urlpc, urlcp));
    QObject::connect(initstruct.broker.get(), SIGNAL(processTasks()),
                     initstruct.zbackend.get(), SLOT(processZMQpool()) );
    initstruct.fbackend.reset((new TConverter(initstruct.broker.get())));
    QObject::connect(initstruct.broker.get(), SIGNAL(processTasks()),
                     initstruct.fbackend.get(), SLOT(doconvert()));
    initstruct.prov.reset( new ColorImageProvider(initstruct.broker.get()));
    QObject::connect(initstruct.broker.get(), SIGNAL(ifldChanged(QString)),
                     initstruct.prov.get(), SLOT(onFolderName(QString)));
    initstruct.mprov.reset( new ColorImageProvider(initstruct.broker.get()));
    QObject::connect(initstruct.broker.get(), SIGNAL(mfldChanged(QString)),
                     initstruct.mprov.get(), SLOT(onFolderName(QString)));

    // by default
    _engine.setObjectOwnership(initstruct.prov.get(), QQmlEngine::JavaScriptOwnership);
    _engine.addImageProvider( QLatin1String("colors"), initstruct.prov.release() );
    _engine.addImageProvider( QLatin1String("mcolors"), initstruct.mprov.release() );
    (void)qmlRegisterSingletonType<TZMQIPC>("ipc.zmq", 1, 0,
                                      "Tipcagent",
                                      getInstance);
    qmlRegisterSingletonType(QUrl("qrc:///qml/TStyle.qml"), "GlobalProp", 1, 0, "TStyle");

    #ifdef QT_DEBUG
    _engine.rootContext()->setContextProperty("QT_DEBUG", QVariant(true));
    #else
    _engine.rootContext()->setContextProperty("QT_DEBUG", QVariant(false));
    #endif // QT_DEBUG
    _engine.load(_url);
    if (_engine.rootObjects().isEmpty())
        return false;
    QObject::connect(initstruct.pyprocess.get(),
                     SIGNAL(finished(int,QProcess::ExitStatus)),
                     initstruct.zbackend.get(),
                     SLOT(processFinished(int, QProcess::ExitStatus)));
    return true;
}


void write_mem_info()
{
    #ifdef Q_OS_LINUX
    struct sysinfo memInfo;
    sysinfo (&memInfo);
    long long int physMemUsed = memInfo.totalram - memInfo.freeram;
    physMemUsed *= memInfo.mem_unit;
    qInfo() << "totalRam:" << (long long int)(memInfo.totalram * memInfo.mem_unit / 1024 / 1024);
    qInfo() << "freeRam:" << (long long int)(memInfo.freeram * memInfo.mem_unit / 1024 / 1024);
    qInfo() << "sharedRam:" << (long long int)memInfo.sharedram * memInfo.mem_unit / 1024 / 1024;
    qInfo() << "bufferRam:" << (long long int)memInfo.bufferram * memInfo.mem_unit / 1024 / 1024;
    qInfo() << "totalSwap:" << (long long int)memInfo.totalswap * memInfo.mem_unit / 1024 / 1024;
    qInfo() << "freeSwap" << (long long int)memInfo.freeswap * memInfo.mem_unit / 1024 / 1024;
    qInfo() << "totalHigh:" << (long long int)memInfo.totalhigh * memInfo.mem_unit / 1024 / 1024;
    qInfo() << "freeHigh:" << (long long int)memInfo.freehigh * memInfo.mem_unit / 1024 / 1024;
    #endif
}
