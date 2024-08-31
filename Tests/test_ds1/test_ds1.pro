#NEW Version
QT += qml quick
QT += quickcontrols2
QT += widgets
QT += testlib
CONFIG += c++11
CONFIG += static
CONFIG += staticlib

#VPATH = $PWD #Что бы файлы подключались относительно оригинального расположения файла
#INCLUDEPATH += $PWD

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS


# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

unix {
    ZPATHINC = "$$_PRO_FILE_PWD_/../../thirdparty/"
    INCLUDEPATH += "/opt/zeromq/only_bin/includes/"
    INCLUDEPATH += $$ZPATHINC
}

SOURCES += \
        main.cpp \
    test_main.cpp


#include(../../app.pro)

HEADERS += \
    test_main.h

DISTFILES += \
    create_log.sh


