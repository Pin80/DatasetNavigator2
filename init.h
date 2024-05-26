#ifndef INIT_H
#define INIT_H

#include <QErrorMessage>
#include "qmlback.h"
#include "zmqtopy.h"
#include <fileconverter.h>

void messageHandler(QtMsgType type,
                    const QMessageLogContext &context,
                    const QString &msg);

bool init(QQmlApplicationEngine& _engine);

struct TInit
{
    QScopedPointer<TBroker> broker;
    std::unique_ptr<ColorImageProvider> prov;
    std::unique_ptr<ColorImageProvider> mprov;
    QScopedPointer< QProcess > pyprocess;
    QScopedPointer<ZMQBackend> zbackend;
    QScopedPointer<TConverter> fbackend;
};

extern TInit initstruct;
extern QScopedPointer<QFile>   m_logFile;

#endif // INIT_H
