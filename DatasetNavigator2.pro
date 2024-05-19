#NEW Version
QT += qml quick
QT += quickcontrols2
QT += widgets
CONFIG += c++11
CONFIG += static
CONFIG += staticlib
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
        init.cpp \
        main.cpp \
        qmlback.cpp \
        zmqtopy.cpp

RESOURCES += \
    qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH += "/home/user/MySoftware/DatasetNavigator2/qml"
# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =
CONFIG += c++11
#/home/user/MySoftware/DatasetNavigator2/thirdparty/
unix {
    ZPATHBIN = "/opt/zeromq/only_bin/lib"
    ZPATHINC = "$$_PRO_FILE_PWD_/thirdparty/"
    INCLUDEPATH += "/opt/zeromq/only_bin/includes/"
    message($$ZPATHINC)
    INCLUDEPATH += $$ZPATHINC
    LIBS += $$ZPATHBIN/libzmq.a
    LIBS += $$ZPATHBIN/libczmq.a
    LIBS += -lpthread
    DEFINES += _GLIBCXX_USE_NANOSLEEP
    target.path = /usr/lib
    INSTALLS += target
    #ZPATH = "/usr/lib/x86_64-linux-gnu"
}

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    init.h \
    qmlback.h \
    zmqtopy.h

DISTFILES += \
    README.md \
    TODO \
    create_copy_to_res_in_build_dir.sh \
    doc/manual.html \
    draft.txt \
    license.txt \
    settings.json \
    zmq_mask_tool.ipynb
