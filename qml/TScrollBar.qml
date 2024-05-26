import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles  1.4
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.1
import QtGraphicalEffects 1.0
import GlobalProp 1.0

ScrollBar {
    property alias sbwidth: polzunok_img.implicitWidth
    contentItem: Rectangle {
        id: polzunok_img
        implicitWidth: sbwidth
        radius: 5*(TStyle.scalekx + TStyle.scaleky)
        onHeightChanged: {
            height = (height < 20*TStyle.scaleky)? 20*TStyle.scaleky:height
        }
        color: TStyle.indicator_hovered
        Image {
            id: img_scroll
            anchors.fill: parent
            fillMode: Image.Stretch
            source: TStyle.indicator_tex
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: img_scroll.width
                    height: img_scroll.height
                    Rectangle {
                        anchors.centerIn: parent
                        width: img_scroll.width
                        height: img_scroll.height
                        radius: Math.min(width, height)
                    }
                }
            }
            MouseArea {
                propagateComposedEvents: true
                anchors.fill: parent
                onWheel:        { wheel.accepted = false; }
                onPressed:      { mouse.accepted = false; }
                onReleased:     { mouse.accepted = false; }
                hoverEnabled: true
                onEntered: parent.source = ""
                onExited: parent.source = TStyle.indicator_tex
            }
        }
    }
}
