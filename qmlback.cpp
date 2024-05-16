#include <QObject>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickView>
#include <QQmlEngine>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QQmlComponent>
#include "qmlback.h"

QObject *getInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    TZMQIPC * inst = TZMQIPC::getInstance(engine,
                                          scriptEngine,
                                          initstruct.jsonObj,
                                          initstruct.pyprocess.get(),
                                          initstruct.zbackend.get(),
                                          initstruct.prov.get());
    return inst;
}

bool init(QQmlApplicationEngine& _engine)
{
    QJsonParseError parseError;
    QJsonDocument jsonDoc;
    QFile fin("settings.json");
    fin.open(QIODevice::ReadOnly);
    if (!fin.isOpen())
    {
        qCritical() << "settings file is not found";
        return false;
    }
    QByteArray ba = fin.readAll();
    jsonDoc = QJsonDocument::fromJson(ba, &parseError);
    if (parseError.error != QJsonParseError::NoError)
    {
        qCritical() << "Parse error at" << parseError.offset << ":" << parseError.errorString();
        return false;
    }
    if (jsonDoc.isNull() || jsonDoc.isEmpty() || !jsonDoc.isObject())
    {
        qCritical() << "No settings is found in settings.json";
        return false;
    }
    initstruct.jsonObj = jsonDoc.object();
    QJsonValue value = initstruct.jsonObj.value("zmqurlpc");
    QString urlpc = value.toString();
    if (urlpc.isEmpty())
    {
        qCritical() << "No annot tool to DN url is found in settings.json";
        return false;
    }
    value = initstruct.jsonObj.value("zmqurlcp");
    QString urlcp = value.toString();
    if (urlcp.isEmpty())
    {
        qCritical() << "No DN to annot tool url is found in settings.json";
        return false;
    }
    initstruct.pyprocess.reset( new QProcess(nullptr));
    QString program = "python3";
    QString scriptFile =  "annot_tool.py";

    QStringList pythonCommandArguments = QStringList() << scriptFile;
    initstruct.pyprocess->start(program, pythonCommandArguments);
    initstruct.pyprocess->waitForStarted();
    initstruct.zbackend.reset(new ZMQBackend(urlpc, urlcp));
    //if (!initstruct.zbackend->startZMQpool())
    {
    //    qCritical() << "zmq backend error";
    //    return false;
    }
    initstruct.prov.reset( new ColorImageProvider());
    qmlRegisterSingletonType<TZMQIPC>("ipc.zmq", 1, 0,
                                      "Tipcagent",
                                      getInstance);
    _engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (_engine.rootObjects().isEmpty())
        return false;
    QObject::connect(initstruct.pyprocess.get(),
                     SIGNAL(finished(int,QProcess::ExitStatus)),
                     initstruct.zbackend.get(),
                     SLOT(processFinished(int, QProcess::ExitStatus)));
    QObject* root = _engine.rootObjects()[0]->findChild<QObject *>("folderlistpanel");
    initstruct.prov->setRootElement(root);
    _engine.addImageProvider( QLatin1String("colors"), initstruct.prov.get() );
    return true;
}
