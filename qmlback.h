#ifndef QMLBACK_H
#define QMLBACK_H

#include <iostream>
#include <QObject>
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

#include "broker.h"
#include <fileconverter.h>

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
                                 TConverter *_cvt,
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
                                const QUrl& path,
                                const QUrl& maskpath,
                                const bool foundMask);
    Q_INVOKABLE bool foundMaskName(const QString& fname,
                                   const QString& path);

    Q_INVOKABLE QString getMaskName(const QString& fname,
                                    const QString& path);

    Q_INVOKABLE QUrl getshortMaskName(const QString& fname,
                                         const QString& path);
    Q_INVOKABLE void convertFiles();
signals:
    void sig_bindSocket();
    void sig_unbindSocket();
    void sig_sendString(QString);
    void sig_cvtFileNames();
    void boundSocket(bool result);
    void unboundSocket(bool result);
    void sentString(bool result);
    void recvString(QUrl result);
    void converted(bool result);
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
    TConverter* m_cvt = nullptr;
    explicit TZMQIPC(TBroker* _broker,
                     QProcess * _proc,
                     ZMQBackend* _zb,
                     TConverter* _cvt,
                     QObject *parent = nullptr);
    ~TZMQIPC();
    explicit TZMQIPC() = delete;
    explicit TZMQIPC(const TZMQIPC&) = delete;
    explicit TZMQIPC(const TZMQIPC&&) = delete;
};


#endif // QMLBACK_H
