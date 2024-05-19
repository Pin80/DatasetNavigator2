#ifndef QMLBACK_H
#define QMLBACK_H

#include <iostream>
#include <QObject>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlEngine>
#include <QtDebug>
#include <QFile>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QProcess>
#include <QPixmap>
#include <QQuickImageProvider>
#include <QFileInfo>
#include <QQuickView>
#include <QQmlComponent>
#include <QQmlContext>

#include "zmqtopy.h"

class TBroker : public QObject
{
    Q_OBJECT
public:
    TBroker()
    {
        QJsonParseError parseError;
        QJsonDocument jsonDoc;
        QFile fin("settings.json");
        fin.open(QIODevice::ReadOnly);
        if (!fin.isOpen())
        {
            qCritical() << "settings file is not found";
            return;
        }
        QByteArray ba = fin.readAll();
        jsonDoc = QJsonDocument::fromJson(ba, &parseError);
        if (parseError.error != QJsonParseError::NoError)
        {
            qCritical() << "Parse error at" << parseError.offset << ":" << parseError.errorString();
            return;
        }
        if (jsonDoc.isNull() || jsonDoc.isEmpty() || !jsonDoc.isObject())
        {
            qCritical() << "No settings is found in settings.json";
            return;
        }
        m_jsonObj = jsonDoc.object();
    }
    Q_PROPERTY(QString imgfolder READ getIFolder WRITE setIFolder NOTIFY ifldChanged)
    QString getIFolder() const
    {
        return m_ifolder;
    }
    void setIFolder(QString _fld)
    {
        m_ifolder = _fld;
    }
    QJsonObject& getSettings()
    {
        return m_jsonObj;
    }
signals:
    void ifldChanged(QString);
private:
    QString m_ifolder;
    QJsonObject m_jsonObj;

};

class ColorImageProvider : public QObject, public QQuickImageProvider
{
    Q_OBJECT
public:
    ColorImageProvider(TBroker * _broker);
    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize) override;
private:
    TBroker * m_broker = nullptr;
    QString m_fld;
public slots:
    void onFolderName(QString _fld);
};


//QObject has neither a copy constructor nor an assignment operator.
class TZMQIPC : public QObject
{
    Q_OBJECT
public:
    static int typeId;
    static TZMQIPC * getInstance(QQmlEngine *engine,
                                 QJSEngine *scriptEngine,
                                 TBroker *_broker,
                                 QProcess * _proc,
                                 ZMQBackend* _zb,
                                 ColorImageProvider* _cvp);

    Q_PROPERTY(QString jsuffix READ getSufText NOTIFY sufChanged)
    QString getSufText() const;

    Q_PROPERTY(QUrl folder READ getFolder WRITE setFolder NOTIFY fldChanged)
    QUrl getFolder() const;
    void setFolder(QUrl _fld);
    Q_PROPERTY(QUrl maskfolder READ getMaskFolder WRITE setMaskFolder NOTIFY mfldChanged)
    QUrl getMaskFolder() const;
    void setMaskFolder(QUrl _fld);
    Q_INVOKABLE void closeWindow();

    Q_INVOKABLE bool sendString(const QString& fname,
                                const QString& path,
                                const QString& maskpath,
                                const bool foundMask);
    Q_INVOKABLE bool foundMaskName(const QString& fname,
                                   const QString& path);

    Q_INVOKABLE QString getMaskName(const QString& fname,
                                    const QString& path);

    Q_INVOKABLE QUrl getshortMaskName(const QString& fname,
                                         const QString& path);
signals:
    void sig_bindSocket();
    void sig_unbindSocket();
    void sig_sendString(QString);
    void boundSocket(bool result);
    void unboundSocket(bool result);
    void sentString(bool result);
    void recvString(QUrl result);
    void urlChanged();
    void sufChanged();
    void folderSet(QString);
    void fldChanged(QString);
    void mfldChanged(QString);
    void pypChanged(QProcess *);
private:
    TBroker* m_broker;
    QString m_suffix;
    QString m_maskprefix;
    QString m_folder;
    QString m_maskfolder;
    QProcess * m_pyprocess = nullptr;
    ZMQBackend* m_zb = nullptr;
    explicit TZMQIPC(TBroker* _broker,
                     QProcess * _proc,
                     ZMQBackend* _zb,
                     QObject *parent = nullptr);
    ~TZMQIPC();
    explicit TZMQIPC() = delete;
    explicit TZMQIPC(const TZMQIPC&) = delete;
    explicit TZMQIPC(const TZMQIPC&&) = delete;
};


#endif // QMLBACK_H
