import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.1

MessageDialog {
    title: qsTr("Error!")
    text: qsTr("Operation is failure")
    icon: StandardIcon.Critical
    Component.onCompleted: visible = false
}
