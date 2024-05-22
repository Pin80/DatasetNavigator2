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
    property alias iwidth:image_frame.sourceSize.width
    property alias iheight:image_frame.sourceSize.height
    width: iwidth + 20
    height: iheight + 20
    ColumnLayout {
        anchors.fill: parent
        Rectangle {
            id: imageDialog_rect
            Layout.alignment: Qt.AlignCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "green"
            border.color: "black"
            border.width: 2
            radius: (10*(image_frame.width + image_frame.height))/350
            Image {
                id: image_frame
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
