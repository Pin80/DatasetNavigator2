import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles  1.4
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel  2.12

ScrollBar {
    id: scrollBar
    property alias sbwidth: polzunok_img.implicitWidth
    readonly property real scalekx: (Screen.desktopAvailableWidth/1920)
    readonly property real scaleky: (Screen.desktopAvailableHeight/1080)
    contentItem: Rectangle {
        id: polzunok_img
        implicitWidth: sbwidth
        color: "brown"
        radius: 10
        onHeightChanged: {
            height = (height < 20*scaleky)? 20*scaleky:height
        }
        MouseArea {
            propagateComposedEvents: true
            anchors.fill: parent
            onWheel:        { wheel.accepted = false; }
            onPressed:      { mouse.accepted = false; }
            onReleased:     { mouse.accepted = false; }
            hoverEnabled: true
            onEntered: polzunok_img.color = "pink"
            onExited: polzunok_img.color = "brown"
        }
    }
}
