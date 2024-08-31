#include <iostream>
#include <QtGlobal>
#include <QIcon>
#include <QApplication>
#include <QLoggingCategory>
#include "init.h"

Q_LOGGING_CATEGORY(lcGcStats, "qt.qml.gc.statistics")
Q_DECLARE_LOGGING_CATEGORY(lcGcStats)
Q_LOGGING_CATEGORY(lcGcAllocatorStats, "qt.qml.gc.allocatorStats")
Q_DECLARE_LOGGING_CATEGORY(lcGcAllocatorStats)

int main(int argc, char *argv[])
{
    try
    {
        Q_UNUSED(argc)
        Q_UNUSED(argv)
        QCoreApplication::setOrganizationName("Some organization");
        QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
        QApplication app(argc, argv);

        if (!log_process())
        {
            std::cerr << "i/o operation error" << std::endl;
            return -1;
        }
        #ifndef QT_DEBUG
        qInstallMessageHandler(messageHandler);
        #endif
        qInfo() << "Qt version is:" << QT_VERSION_STR;
        if ( (QT_VERSION_MAJOR < 5) || (QT_VERSION_MINOR < 12))
        {
            qCritical() << "Qt version is not compitable:";
            return -1;
        }
        if ((QT_VERSION_MINOR != 12) || (QT_VERSION_PATCH != 12))
        {
            qWarning() << "Qt version is not fully mathced. Qt library may be not fully compitable";
        }
        if (ZMQ_VERSION_MAJOR != 4 || ZMQ_VERSION_MINOR != 3)
        {
            qWarning() << "ZMQ version is not fully mathced. ZMQ library may be not fully compitable";
        }
        write_mem_info();
        // Под Gnome не работает
        app.setWindowIcon(QIcon("./images/favicon.png"));

        int result = 0;
        {
            initstruct.broker.reset(new TBroker);
            //initstruct.broker->stop();
            //return -1;
            QQmlApplicationEngine engine(&app);
            const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
            QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                             &app, [url](QObject *obj, const QUrl &objUrl)
            {
                if (!obj && url == objUrl)
                {
                    initstruct.broker->stop();
                    QCoreApplication::exit(-1);
                }
            }, Qt::QueuedConnection);
            if (!init(engine, url))
            {
                std::cout << "exit" << std::endl;
                initstruct.broker->stop();
                return -1;
            }

            result = app.exec();
            initstruct.broker->stop();
            //return result;
            if (initstruct.zbackend)
            {
                initstruct.zbackend->terminateZMQ_pool();
                initstruct.zbackend.reset(nullptr);
            }
        }
        if (initstruct.pyprocess)
        {
            if (initstruct.pyprocess->state() == QProcess::ProcessState::Running)
            {
                QByteArray ar("q");
                initstruct.pyprocess->write(ar);
                initstruct.pyprocess->waitForBytesWritten(3000);
                initstruct.pyprocess->closeWriteChannel();
                initstruct.pyprocess->waitForFinished(1000);
            }
        }
        initstruct.broker.reset();
        qInfo() << "DN Application is terminated";
        return result;
    }
    catch (const std::runtime_error& _err)
    {
        std::cerr  << _err.what() << std::endl;
    }
    catch (...)
    {
        std::cerr  << "unknown error" << std::endl;
    }
    return -1;
}
