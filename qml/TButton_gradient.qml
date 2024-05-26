import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.0
import QtGraphicalEffects 1.0
import GlobalProp 1.0

Rectangle {
    id: control
    property string btntext: qsTr("Button")
    property bool is_pressed: false
    property bool is_hovered: false
    border.color: TStyle.background
    border.width: 3
    readonly property string btncolorH: "#ffad00"
    readonly property string btncolorP: "#8e4e00"
    readonly property string btncolorP2: "#af6700"
    readonly property string btncolorSH: "#8e4e00"
    readonly property string btncolorNP: "#ff6700"
    readonly property string btncolorSH2: "#a1395847"
    color: btncolorSH2
    RowLayout {
        id: btn_layout
        spacing: 0
        anchors.fill: parent
        property string currcolorNP: is_hovered ? control.btncolorH : control.btncolorNP
        property string currcolor: is_pressed ? control.btncolorP : currcolorNP
        Rectangle {
            id: rect0
            color: control.btncolorSH
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
                           position: 1.0 ; color: is_pressed ? control.btncolorP2: control.btncolorP
                       }
                }
            }
         }
        Rectangle {
            id: rect
            color: control.btncolorSH
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
                           position: 0.0 ; color: is_pressed ? control.btncolorP2 : control.btncolorP
                       }
                       GradientStop {
                           id: grad1stop2
                           position: 0.5 ; color: btn_layout.currcolor
                       }
                       GradientStop {
                           id: grad1stop3
                           position: 1.0 ; color: is_pressed ? control.btncolorP2: control.btncolorP
                       }
                }
            }
            Text {
                id: btn_text
                anchors.fill: parent
                elide: Text.ElideLeft
                font.pointSize: TStyle.scaleky*14
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: btntext
                font.bold: true
            }
         }
        Rectangle {
            id: rect2
            color: control.btncolorSH
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
                           position: 1.0 ; color: is_pressed ? control.btncolorP2: control.btncolorP
                       }
                }
            }
         }
    }
}
