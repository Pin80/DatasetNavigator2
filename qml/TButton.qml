import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel 2.0
import QtQuick.Window 2.12

RoundButton {
    id: custom_button
    text: "Button"
    radius: 10
    property real scalekx: (Screen.desktopAvailableWidth/1920)
    property real scaleky: (Screen.desktopAvailableHeight/1080)
    property alias grad: rect.gradient
    background: Rectangle {
        id: rect
         color: "green"
         border.color: custom_button.down ? "#FA8072" : "#696969"
         border.width: 3
         radius: 10
     }
    font.pixelSize: scaleky*14
}
