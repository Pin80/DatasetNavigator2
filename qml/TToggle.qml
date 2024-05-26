import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import GlobalProp 1.0

RoundButton {
    id: control
    text: "To"
    radius: 5*(TStyle.scalekx + TStyle.scaleky)
    flat: false
    palette.button: ishovered ? TStyle.indicator_hovered : TStyle.indicator
    palette.dark: TStyle.indicator_pressed
    palette.buttonText: TStyle.indicator_text
    palette.brightText: TStyle.indicator_intext
    property bool  ishovered: false
    property bool  ispressed: false
    Image {
        anchors.fill: parent
        source: (control.ishovered || ispressed) ? "" : TStyle.indicator_tex
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Item {
                width: control.width
                height: control.height
                Rectangle {
                    anchors.centerIn: parent
                    width: control.width
                    height: control.height
                    radius: control.radius
                }
            }
        }
    }
}
