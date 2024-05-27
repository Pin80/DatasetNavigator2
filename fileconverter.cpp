#include "fileconverter.h"

TConverter::TConverter(TBroker *_broker)
    : m_broker(_broker)
{
    m_start = false;
    m_prefix = "image_";
    m_startIdx = 1;
}

void TConverter::onStartConvert(QString _prefiz, QString _path)
{
    m_prefix = _prefiz;
    m_folder = _path;
    m_startIdx = 1;
    m_reindex = false;
    m_start = true;
}

void TConverter::onStartReindex(QString _prefiz, QString _path, int _start)
{
    m_prefix = _prefiz;
    m_folder = _path;
    m_startIdx = _start;
    m_reindex = true;
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
    int idx = m_startIdx;
    int count = 0;
    QRegularExpression exp("^.*" + m_suffix + "\\d+\\.png$");
    const auto max_idx = 10000;
    QString repname = m_folder + "/report.txt";
    QFile report(repname);
    if (!report.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        emit converted(0);
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
        if (match.hasMatch() && !m_reindex)
            continue;
        QString newname;

        while ((idx <= max_idx) && ((!match.hasMatch()) || m_reindex))
        {
            QString number = QStringLiteral("%1").arg(idx, 5, 10, QLatin1Char('0'));
            newname = path + "/" + m_prefix + m_suffix + number + ".png";// + fext;
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
            emit converted(0);
            break;
        }
        else
        {
            if (!QFileInfo(newname).exists())
            {
                QString oldfullname = m_folder + "/" + filename;
                QImage img;
                if (img.load(oldfullname))
                {
                    img.save(newname);
                    QFile::remove(oldfullname);
                    out << "old:" << oldfullname << "  new:" << newname << '\n';
                    result = true;
                    count++;
                }
                else
                {
                    out << "error: old:" << oldfullname << "  new:" << newname << '\n';
                }
            }
        }
        idx++;
    }
    report.close();
    emit converted(count);
    m_start = false;
}

