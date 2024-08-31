#ifndef TEST_MAIN_H
#define TEST_MAIN_H
#include <QTest>
#include <QProcess>
#include <zmq.hpp>

class TestMain: public QObject
{
    Q_OBJECT
private:
    QScopedPointer<QFile>   m_logFile;
    QFileInfo logInfo;
private slots:
    void initTestCase()
    {
        #ifdef Q_OS_LINUX
        //QVERIFY(QProcess::execute("/bin/bash", QStringList() << "-c" << QString("./create_log.sh")) == 0);
        #else
        QFAIL("Tests only for linux")
        #endif
    }
    void logfile_check()
    {
        /*
        const char * logfname = "datasetnavigator.log";
        logInfo.setFile(logfname);
        // simple log rotation
        QVERIFY(logInfo.exists());
        QDir directory("");
        QDateTime current = QDateTime::currentDateTime();
        QDateTime created = logInfo.created();
        int days = created.daysTo(current);
        qDebug() << "current date:" << current;
        qDebug() << "file date:" << created;
        QVERIFY(days > 0);
        QStringList logs = directory.entryList(QStringList() << "*.log" ,QDir::Files);
        foreach(QString filename, logs)
        {
            QVERIFY(!filename.isEmpty());
            QVERIFY(filename.contains(logfname) );
            // delete old logs
            if(filename.size() > QString(logfname).size())
            {
                qDebug() << "fsize:" << filename.size();
                qDebug() << "fsize:" << QString(logfname).size();
                directory.remove(filename);
            }
        }
        QString newname = logInfo.baseName() + "_" + created.toString("dd.MM.yyyy") + "." + logInfo.completeSuffix();
        QFile::rename(logfname, newname);
        m_logFile.reset(new QFile(logfname));
        m_logFile.data()->open(QFile::Append | QFile::Text);
        QVERIFY(m_logFile->isOpen());
        */
        //qInstallMessageHandler(messageHandler);
    }
    void version_check()
    {
        qDebug() << "Qt version is:" << QT_VERSION_STR;
        QVERIFY(QT_VERSION_MAJOR == 5);
        QVERIFY(QT_VERSION_MINOR >= 12);
        QVERIFY(ZMQ_VERSION_MAJOR == 4 && ZMQ_VERSION_MINOR == 3);
    }
};


#endif // TEST_MAIN_H
