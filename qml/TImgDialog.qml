import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import QtQuick.Window 2.0
import GlobalProp 1.0

Window{
    id: control
    title: qsTr("Image:")
    color: TStyle.background_small
    visible: false
    property bool autoscale: false
    property string fname: ""
    property alias iwidth: control.width
    property alias iheight: control.height
    minimumWidth: 100*TStyle.scalekx
    minimumHeight: 100*TStyle.scaleky
    ColumnLayout {
        id: imglay
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
            Flickable {
                id: flickimg
                anchors.fill: parent
                contentWidth: (autoscale)?parent.width:Math.max(image_frame.width * image_frame.scale, imageDialog_rect.width)
                contentHeight: (autoscale)?parent.height:Math.max(image_frame.height * image_frame.scale, imageDialog_rect.height)
                clip: true
                Image {
                    id: image_frame
                    property real zoom: 0.0
                    property real zoomStep: 0.1
                    anchors.centerIn: image_frame.parent
                    anchors.fill: (autoscale)?parent:undefined
                    anchors.margins: (iwidth/350)*10
                    fillMode: Image.PreserveAspectFit
                    source: fname
                    asynchronous: true
                    cache: false
                    smooth: true
                    antialiasing: true
                    mipmap: true
                    transformOrigin: Item.Center
                    property double minimgwidth: (imageDialog_rect.width - imageDialog_rect.radius)/ width
                    property double minimgheight: (imageDialog_rect.height - imageDialog_rect.radius)/ height
                    scale: Math.min(minimgwidth, minimgheight, 1) + zoom
                    MouseArea {
                        anchors.fill: parent
                        onDoubleClicked: {
                            if (!autoscale) {
                                image_frame.zoom = 0.0
                                control.autoscale = true
                                image_frame.anchors.centerIn = undefined
                            }
                            else
                            {
                                control.autoscale = false
                                image_frame.anchors.centerIn = image_frame.parent
                            }
                            control.title = fname + " " + (image_frame.zoom + 1)
                        }
                    }
                }
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: {
            if (!autoscale) {
                if (wheel.angleDelta.y > 0)
                    image_frame.zoom = Number((image_frame.zoom + image_frame.zoomStep).toFixed(1))
                else
                    if (image_frame.zoom > 0) image_frame.zoom = Number((image_frame.zoom - image_frame.zoomStep).toFixed(1))
                control.title = fname + " " + (image_frame.zoom + 1)
            }
            wheel.accepted=true
        }
    }
}
