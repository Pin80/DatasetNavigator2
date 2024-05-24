import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles  1.4
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.1
import GlobalProp 1.0

ScrollBar {
    property alias sbwidth: polzunok_img.implicitWidth
    contentItem: Rectangle {
        id: polzunok_img
        implicitWidth: sbwidth
        color: TStyle.indicator
        radius: 5*(TStyle.scalekx + TStyle.scaleky)
        onHeightChanged: {
            height = (height < 20*TStyle.scaleky)? 20*TStyle.scaleky:height
        }
        MouseArea {
            propagateComposedEvents: true
            anchors.fill: parent
            onWheel:        { wheel.accepted = false; }
            onPressed:      { mouse.accepted = false; }
            onReleased:     { mouse.accepted = false; }
            hoverEnabled: true
            onEntered: parent.color = TStyle.indicator_hovered
            onExited: parent.color = TStyle.indicator
        }
    }
}
