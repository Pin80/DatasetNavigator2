import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel 2.0

Rectangle {
    id: lineedit
    Layout.alignment: Qt.AlignRight
    Layout.fillWidth: true
    Layout.preferredHeight: 30
    Layout.preferredWidth: 40
    border.color: "black"
    border.width: 2
    radius: 5
    color: "lightblue"
    property alias text: txtedit.text
    TextEdit {
        id: txtedit
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.topMargin: 3
        anchors.bottomMargin: 3
        focus: true
        font.family: "Helvetica"
        font.pointSize: 14
        text: "simple text"
        color: "black"
    }
}
