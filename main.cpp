#include <iostream>
#include <QtGlobal>
#include <QIcon>
#include "init.h"

int main(int argc, char *argv[])
{
    try
    {
        const QString good_qt_version = "5.12";
        QGuiApplication::setOrganizationName("Some organization");
        QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
        QGuiApplication app(argc, argv);
        m_logFile.reset(new QFile("datasetnavigator.log"));
        m_logFile.data()->open(QFile::Append | QFile::Text);
        if (!m_logFile->isOpen())
            return -1;
        #ifndef QT_DEBUG
        qInstallMessageHandler(messageHandler);
        #endif
        qInfo() << "Qt version is:" << QT_VERSION_STR;
        if ( (QT_VERSION_MAJOR < 5) || (QT_VERSION_MINOR < 10))
        {
            qCritical() << "Qt version is bad:";
            return -1;
        }
        if ((QT_VERSION_MINOR != 12) || (QT_VERSION_PATCH != 12))
        {
            qWarning() << "Qt version is not mathced. library may not be fully compitable";
        }
        if (ZMQ_VERSION_MAJOR != 4 || ZMQ_VERSION_MINOR != 3)
        {
            qWarning() << "Qt version is not mathced. library may not be fully compitable";
        }
        // Под Gnome не работает
        app.setWindowIcon(QIcon("./images/favicon.png"));
        QQmlApplicationEngine engine;
        if (!init(engine))
            return -1;
        int result = app.exec();
        initstruct.zbackend->terminateZMQ_pool();
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
}
