import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel 2.0
import QtQuick.Window 2.0

Window{
    id: imageDialog
    title: "Image"
    color: "brown"
    visible: false
    property string fname: ""
    ColumnLayout {
        anchors.fill: parent
        Rectangle {
            Layout.alignment: Qt.AlignRight
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "green"
            border.color: "black"
            border.width: 2
            radius: (imageDialog.width/350)*10
            Image {
                id: image_frame2
                anchors.fill: parent
                anchors.margins: (imageDialog.width/350)*10
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter
                fillMode: Image.PreserveAspectFit
                autoTransform: true
                Layout.alignment: Qt.AlignHCenter
                source: imageDialog.fname
                scale: Qt.KeepAspectRatio
            }
        }
    }
}
