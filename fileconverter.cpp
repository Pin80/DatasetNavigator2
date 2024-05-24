#include "fileconverter.h"

TConverter::TConverter(TBroker *_broker)
    : m_broker(_broker)
{
    m_start = false;
    connect(m_broker, SIGNAL(ifldChanged(QString)), this, SLOT(onFolderName(QString)));
}

void TConverter::onStartConvert()
{
    m_start = true;
}

void TConverter::doconvert()
{
    bool result = true;
    if (!m_start)
    {
        return;
    }
    QDir directory(m_folder);
    QStringList images = directory.entryList(QStringList() << "*.jpg" << "*.JPG" << "*.png",QDir::Files);
    QJsonValue value = m_broker->getSettings().value("suffix");
    m_suffix = value.toString();
    m_prefix = "image_";
    int idx = 1;
    QRegularExpression exp("^.*" + m_suffix + "\\d+\\.(?:jpg|png|jpeg)$");
    const auto max_idx = 10000;
    QString repname = m_folder + "/report.txt";
    QFile report(repname);
    if (!report.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        emit converted(false);
        return;
    }
    QTextStream out(&report);
    foreach(QString filename, images)
    {
        QFileInfo fi = QFileInfo(filename);
        QString bname = fi.baseName();
        QString path = m_folder;
        QString fext = fi.suffix();
        QRegularExpressionMatch match = exp.match(filename);
        // +reindex
        if (match.hasMatch())
            continue;
        QString newname;

        while ((idx <= max_idx) && (!match.hasMatch()))
        {
            QString number = QStringLiteral("%1").arg(idx, 5, 10, QLatin1Char('0'));
            newname = path + "/" + m_prefix + m_suffix + number + "." + fext;
            if (QFileInfo(newname).exists())
            {
                idx++;
            }
            else
            {
                break;
            }
        }
        if (idx > max_idx)
        {
            emit converted(false);
            break;
        }
        else
        {
            if (!QFileInfo(newname).exists())
            {
                QString oldfullname = m_folder + "/" + filename;
                QFile::rename(oldfullname, newname);
                out << "old:" << oldfullname << "  new:" << newname << '\n';
                result = true;
            }
        }
        idx++;
    }
    report.close();
    emit converted(result);
    m_start = false;
}

void TConverter::onFolderName(QString _fld)
{
    m_folder = _fld;
}
