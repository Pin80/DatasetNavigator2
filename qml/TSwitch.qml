import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles  1.4
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel  2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.12
import GlobalProp 1.0

Switch {
    id: control
    font.pointSize: TStyle.scaleky*14
    property bool ishovered: false
    TMsgDialog {
        id : errordialog2
    }
    indicator: Rectangle {
        id: indicswitch
        implicitWidth: 2*indicswitchbtn.width + indicswitchbtn.border.width
        implicitHeight: indicswitchbtn.height + indicswitchbtn.border.width
        x: control.leftPadding
        y: control.height / 2 - control.height / 2
        radius: indicswitchbtn.radius + indicswitchbtn.border.width
        color: control.checked ? TStyle.indicator_on: TStyle.background_small
        border.color: TStyle.background_border
        Rectangle {
            id: indicswitchbtn
            x: control.checked ? parent.width - 2*parent.radius : 0
            y: control.height / 2 - control.height / 2
            width: 26*TStyle.scalekx
            height: 26*TStyle.scaleky
            radius: width/2
            color: ishovered ? TStyle.indicator_hovered : TStyle.indicator
            border.width: 2
            border.color:  TStyle.background_border
            Image {
                id: img_switch
                anchors.fill: parent
                fillMode: Image.Tile
                source: control.ishovered ? "" : TStyle.indicator_tex
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Item {
                        width: indicswitchbtn.width
                        height: indicswitchbtn.height
                        Rectangle {
                            anchors.centerIn: parent
                            width: indicswitchbtn.width - indicswitchbtn.border.width
                            height: indicswitchbtn.height - indicswitchbtn.border.width
                            radius: indicswitchbtn.radius  - indicswitchbtn.border.width
                        }
                    }
                }
            }
        }
    }
    contentItem: Text {
        id: txtswitch
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        verticalAlignment: Text.AlignVCenter
        leftPadding: (indicswitch.width + 5)
    }
}
