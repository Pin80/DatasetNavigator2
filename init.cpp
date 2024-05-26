#include "init.h"

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

bool init(QQmlApplicationEngine& _engine)
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
    _engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (_engine.rootObjects().isEmpty())
        return false;
    QObject::connect(initstruct.pyprocess.get(),
                     SIGNAL(finished(int,QProcess::ExitStatus)),
                     initstruct.zbackend.get(),
                     SLOT(processFinished(int, QProcess::ExitStatus)));
    return true;
}

