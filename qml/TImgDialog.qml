import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import QtQuick.Window 2.0
import GlobalProp 1.0

Window{
    id: control
    title: qsTr("Image")
    color: TStyle.background_small
    visible: false
    property string fname: ""
    property alias iwidth: control.width
    property alias iheight: control.height
    minimumWidth: 100*TStyle.scalekx
    minimumHeight: 100*TStyle.scaleky
    ColumnLayout {
        anchors.fill: parent
        Rectangle {
            id: imageDialog_rect
            Layout.alignment: Qt.AlignCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: TStyle.background
            border.color: TStyle.background_border
            border.width: 2
            width: parent.width*0.9
            height: parent.height*0.9
            radius: TStyle.scalekx*(10*(image_frame.width + image_frame.height))/350
            Image {
                id: image_frame
                anchors.fill: parent
                anchors.margins: (iwidth/350)*10
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter
                fillMode: Image.PreserveAspectFit
                autoTransform: true
                Layout.alignment: Qt.AlignHCenter
                source: fname
                scale: Qt.KeepAspectRatio
                sourceSize.width: width
                sourceSize.height: height
            }
        }
    }
}
