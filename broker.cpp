#include "broker.h"

    TBroker::TBroker()
    {
        QJsonParseError parseError;
        QJsonDocument jsonDoc;
        QFile fin("settings.json");
        fin.open(QIODevice::ReadOnly);
        if (!fin.isOpen())
        {
            qCritical() << "settings file is not found";
            throw std::runtime_error("settings file is not found");
            return;
        }
        QByteArray ba = fin.readAll();
        jsonDoc = QJsonDocument::fromJson(ba, &parseError);
        if (parseError.error != QJsonParseError::NoError)
        {
            qCritical() << "Parse error at" << parseError.offset << ":" << parseError.errorString();
            throw std::runtime_error("Parse error");
            return;
        }
        if (jsonDoc.isNull() || jsonDoc.isEmpty() || !jsonDoc.isObject())
        {
            qCritical() << "No settings is found in settings.json";
            throw std::runtime_error("No settings is found in settings.json");
            return;
        }
        m_jsonObj = jsonDoc.object();
        m_future = QtConcurrent::run(this, & TBroker::processBroker);
    }

    TBroker::~TBroker()
    {
        if (m_isrunning)
        {
            m_isrunning = false;
            m_future.waitForFinished();
        }
    }

    void TBroker::processBroker()
    {
        m_isrunning = true;
        while(m_isrunning)
        {
            emit processTasks();
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
        }
    }
