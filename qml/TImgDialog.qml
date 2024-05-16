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
    maximumHeight: height
    maximumWidth: width
    color: "brown"
    visible: false
    property string fname: ""
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 3
        Rectangle {
            Layout.alignment: Qt.AlignRight
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredHeight: 5
            Layout.preferredWidth: 5
            color: "green"
            border.color: "black"
            border.width: 2
            radius: 10
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 2
                Image {
                    id: image_frame2
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    fillMode: Image.PreserveAspectFit
                    clip:true
                    Layout.alignment: Qt.AlignHCenter
                    source: imageDialog.fname
                    scale: Qt.KeepAspectRatio
                    width: 10
                    height: 10
                }
            }
        }
    }
}
