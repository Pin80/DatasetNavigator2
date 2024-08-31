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


TEMPLATE = subdirs
SUBDIRS += \
    Tests/test_ds1 \
    app.pro


