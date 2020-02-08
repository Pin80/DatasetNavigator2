import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel 2.0

Button {
    id: custom_button
    Layout.alignment: Qt.AlignRight
    Layout.fillWidth: true
    Layout.preferredHeight: 40
    Layout.preferredWidth: 40
    text: "Button"
    background: Rectangle {
         implicitWidth: 10
         implicitHeight: 10
         color: "gray"
         border.color: custom_button.down ? "#FA8072" : "#696969"
         border.width: 3
         radius: 10
         gradient: Gradient {
             GradientStop {
                 position: 0 ; color: custom_button.pressed ? "#ccc" : "#eee"
             }
             GradientStop {
                 position: 1 ; color: custom_button.pressed ? "#aaa" : "#ccc"
             }
         }
     }
}
