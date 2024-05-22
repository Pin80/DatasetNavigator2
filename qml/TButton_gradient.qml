import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel 2.0
import QtGraphicalEffects 1.0

Rectangle {
    id: custom_button
    property string text: "Button"
    readonly property real scalekx: (Screen.desktopAvailableWidth/1920)
    readonly property real scaleky: (Screen.desktopAvailableHeight/1080)
    property bool is_pressed: false
    property bool is_hovered: false
    border.color: "green"
    border.width: 3
    color: "#a1395847"
    RowLayout {
        id: btn_layout
        spacing: 0
        anchors.fill: parent
        property string currcolorNP: is_hovered ? currcolorH : "#ff6700"
        readonly property string currcolorH: "#ffad00"
        readonly property string currcolorP: "#8e4e00"
        readonly property string currcolorP2: "#af6700"
        property string currcolor: is_pressed ? currcolorP : currcolorNP
        Rectangle {
            id: rect0
            color: "#8e4e00"
            Layout.fillHeight: true
            Layout.topMargin: is_pressed ? 6 : 2
            Layout.leftMargin: is_pressed ? 6 : 2
            Layout.bottomMargin: 2
            Layout.maximumWidth: height
            Layout.minimumWidth: height
            RadialGradient  {
               id: grad0
               anchors.fill: parent
               anchors.topMargin: is_pressed ? 2 : 0
               anchors.leftMargin: is_pressed ? 4 : 0
               anchors.bottomMargin: is_pressed ? 2 : 0
               verticalRadius: height/2
               horizontalRadius: height
               horizontalOffset: height/2
               source: rect0
                   gradient: Gradient {
                       GradientStop {
                           id: grad0stop1
                           position: 0.0 ; color: btn_layout.currcolor
                       }
                       GradientStop {
                           id: grad0stop3
                           position: 1.0 ; color: is_pressed ? btn_layout.currcolorP2:  btn_layout.currcolorP
                       }
                }
            }
         }
        Rectangle {
            id: rect
            color: "#8e4e00"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: is_pressed ? 6 : 2
            Layout.bottomMargin: 2
            LinearGradient  {
               id: grad1
               anchors.fill: parent
               anchors.topMargin: is_pressed ? 2 : 0
               anchors.bottomMargin: is_pressed ? 2 : 0
               source: rect
                   gradient: Gradient {
                       GradientStop {
                           id: grad1stop1
                           position: 0.0 ; color: is_pressed ? btn_layout.currcolorP2 :  btn_layout.currcolorP
                       }
                       GradientStop {
                           id: grad1stop2
                           position: 0.5 ; color: btn_layout.currcolor
                       }
                       GradientStop {
                           id: grad1stop3
                           position: 1.0 ; color: is_pressed ? btn_layout.currcolorP2:  btn_layout.currcolorP
                       }
                }
            }
            Text {
                id: btn_text
                anchors.fill: parent
                elide: Text.ElideLeft
                font.pointSize: scaleky*14
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: custom_button.text
                font.bold: true
            }
         }
        Rectangle {
            id: rect2
            color: "#8e4e00"
            Layout.fillHeight: true
            Layout.topMargin: is_pressed ? 6 : 2
            Layout.rightMargin: 2
            Layout.bottomMargin: 2
            Layout.maximumWidth: height
            Layout.minimumWidth: height
            RadialGradient  {
               id: grad2
               anchors.fill: parent
               anchors.topMargin: is_pressed ? 2 : 0
               anchors.rightMargin: is_pressed ? 4 : 0
               anchors.bottomMargin: is_pressed ? 2 : 0
               verticalRadius: height/2
               horizontalRadius: height
               horizontalOffset: -height/2
               source: rect2
                   gradient: Gradient {
                       GradientStop {
                           id: grad2stop1
                           position: 0.0 ; color: btn_layout.currcolor
                       }
                       GradientStop {
                           id: grad2stop3
                           position: 1.0 ; color: is_pressed ? btn_layout.currcolorP2:  btn_layout.currcolorP
                       }
                }
            }
         }
    }
}
