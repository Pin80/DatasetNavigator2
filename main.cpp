#include <iostream>
#include <QtGlobal>
#include <QIcon>
#include "init.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    try
    {
        const QString good_qt_version = "5.12";
        QCoreApplication::setOrganizationName("Some organization");
        QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
        QApplication app(argc, argv);
        m_logFile.reset(new QFile("datasetnavigator.log"));
        m_logFile.data()->open(QFile::Append | QFile::Text);
        if (!m_logFile->isOpen())
            return -1;
        //#ifndef QT_DEBUG
        qInstallMessageHandler(messageHandler);
        //#endif
        qInfo() << "Qt version is:" << QT_VERSION_STR;
        if ( (QT_VERSION_MAJOR < 5) || (QT_VERSION_MINOR < 10))
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
        // Под Gnome не работает
        app.setWindowIcon(QIcon("./images/favicon.png"));
        int result = 0;
        {
            initstruct.broker.reset(new TBroker);
            QQmlApplicationEngine engine(&app);
            if (!init(engine))
                return -1;
            result = app.exec();
            initstruct.zbackend->terminateZMQ_pool();
            initstruct.zbackend.reset(nullptr);
        }
        if (initstruct.pyprocess->state() == QProcess::ProcessState::Running)
        {
            QByteArray ar("q");
            initstruct.pyprocess->write(ar);
            initstruct.pyprocess->waitForBytesWritten(3000);
            initstruct.pyprocess->closeWriteChannel();
            initstruct.pyprocess->waitForFinished(1000);
        }
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
