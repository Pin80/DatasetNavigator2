QT += qml quick
QT += quickcontrols2
CONFIG += c++11

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS


# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        main.cpp \
        qmlback.cpp \
        zmqtopy.cpp

RESOURCES += \
    qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH += "/home/user/MySoftware/DatasetNavigator/DatasetNavigator/qml"
# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =
CONFIG += c++11
unix {
    target.path = /usr/lib
    INSTALLS += target
    ZPATH = "/usr/lib/x86_64-linux-gnu"
    LIBS += $$ZPATH/libzmq.so
    LIBS += $$ZPATH/libczmq.so
    LIBS += $$ZPATH/libzmqpp.so
}

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    qmlback.h \
    zhelpers.h \
    zmqtopy.h

DISTFILES += \
    draft.txt \
    settings.json \
    zmq_mask_tool.ipynb
