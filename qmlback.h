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

class ColorImageProvider : public QObject, public QQuickImageProvider
{
    Q_OBJECT
public:
    ColorImageProvider(QObject * _main = nullptr);


    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize) override;
    void setRootElement(QObject * _main);
private:
    QObject * m_main = nullptr;
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
                                 const QJsonObject& _jobj,
                                 QProcess * _proc,
                                 ZMQBackend* _zb,
                                 ColorImageProvider* _cvp);

    Q_PROPERTY(QString jsuffix READ getSufText NOTIFY sufChanged);
    QString getSufText() const;

    Q_PROPERTY(QUrl folder READ getFolder WRITE setFolder NOTIFY fldChanged);
    QUrl getFolder() const;
    void setFolder(QUrl _fld);
    Q_PROPERTY(QUrl maskfolder READ getMaskFolder WRITE setMaskFolder NOTIFY mfldChanged);
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
    const QJsonObject m_jobj;
    QString m_suffix;
    QString m_maskprefix;
    QString m_folder;
    QString m_maskfolder;
    QProcess * m_pyprocess = nullptr;
    ZMQBackend* m_zb = nullptr;
    ColorImageProvider* m_cvp = nullptr;
    explicit TZMQIPC(const QJsonObject& _jobj,
                     QProcess * _proc,
                     ZMQBackend* _zb,
                     ColorImageProvider* _cvp,
                     QObject *parent = nullptr);
    ~TZMQIPC();
    explicit TZMQIPC() = delete;
    explicit TZMQIPC(const TZMQIPC&) = delete;
    explicit TZMQIPC(const TZMQIPC&&) = delete;
};


#endif // QMLBACK_H
