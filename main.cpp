#include <iostream>
#include <QtGlobal>
#include <QIcon>
#include "init.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    try
    {
        Q_UNUSED(argc)
        Q_UNUSED(argv)
        const char * logfname = "datasetnavigator.log";
        QCoreApplication::setOrganizationName("Some organization");
        QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
        QApplication app(argc, argv);
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
                QString newname = created.toString() + "_" + logfname;
                QFile::rename(logfname, newname);
            }
        }

        m_logFile.reset(new QFile(logfname));
        m_logFile.data()->open(QFile::Append | QFile::Text);
        if (!m_logFile->isOpen())
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

        // Под Gnome не работает
        app.setWindowIcon(QIcon("./images/favicon.png"));

        int result = 0;
        {
            initstruct.broker.reset(new TBroker);
            //initstruct.broker->stop();
            //return -1;
            QQmlApplicationEngine engine(&app);
            if (!init(engine))
            {
                std::cout << "exit" << std::endl;
                initstruct.broker->stop();
                return -1;
            }
            result = app.exec();
            //initstruct.broker->stop();
            //return result;
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
