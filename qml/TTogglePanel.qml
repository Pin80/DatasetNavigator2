import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles  1.4
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel  2.0
import QtQuick.Controls.Material 2.12
import GlobalProp 1.0

Item {
    id : toggle_panel
    property bool toggle_im: true
    property bool isBound: false
    signal sig_bind()
    signal sig_unbind()
    RowLayout {
        anchors.fill: parent
        spacing: 2
        anchors.margins: 2
        Switch {
            id: toggle_bind2
            text: qsTr("Connect")
            font.pointSize: TStyle.scaleky*14
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            checked: isBound
            TMsgDialog {
                id : errordialog2
            }

            indicator: Rectangle {
                id: indicswitch
                implicitWidth: 2*indicswitchbtn.width
                implicitHeight: toggle_panel.height - 2
                x: toggle_bind2.leftPadding
                y: parent.height / 2 - toggle_panel.height / 2
                radius: indicswitchbtn.radius
                color: toggle_bind2.checked ? TStyle.indicator_on: TStyle.background_small
                border.color: TStyle.background_border

                Rectangle {
                    id: indicswitchbtn
                    x: toggle_bind2.checked ? parent.width - 2*radius : 0
                    implicitWidth: 26*TStyle.scalekx
                    implicitHeight: implicitWidth
                    radius: implicitWidth/2
                    color: TStyle.indicator
                    border.color:  TStyle.background_border
                }
            }

            contentItem: Text {
                id: txtswitch
                text: toggle_bind2.text
                font: toggle_bind2.font
                opacity: enabled ? 1.0 : 0.3
                verticalAlignment: Text.AlignVCenter
                leftPadding: (indicswitch.width + 5)
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                property color oldcolor : TStyle.indicator
                onClicked: {
                    console.log("zmq Button Pressed.");
                    var result = false
                    if (isBound) {
                        sig_unbind()
                    }
                    else {
                        sig_bind()
                    }
                }
                onEntered: {
                        oldcolor = indicswitchbtn.color
                        indicswitchbtn.color = TStyle.indicator_hovered
                }
                onExited: {
                        indicswitchbtn.color = oldcolor
                }
            }
        }
        TToggle {
            id: toggle_i
            text: qsTr("Im")
            checked: toggle_im
            checkable: !toggle_im
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            Layout.preferredWidth: parent.width*0.2
            palette.button: TStyle.indicator
            palette.dark: TStyle.indicator_pressed
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                property color oldcolor : TStyle.indicator
                onEntered: {
                    if (!toggle_im) {
                        oldcolor = toggle_i.palette.button
                        toggle_i.palette.button = TStyle.indicator_hovered
                    }
                }
                onExited: {
                    if (!toggle_im) {
                        toggle_i.palette.button = oldcolor
                    }
                }
                onPressed: {
                    if (!toggle_im) {
                        toggle_im = true
                        toggle_m.palette.button = TStyle.indicator
                        toggle_i.palette.dark = TStyle.indicator_pressed
                    }
                }
             }
        }
        TToggle {
            id: toggle_m
            text: qsTr("Msk")
            checked: !toggle_im
            checkable: toggle_im
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            Layout.preferredWidth: parent.width*0.2
            palette.button: TStyle.indicator
            palette.dark: TStyle.indicator_pressed
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                property color oldcolor : TStyle.indicator
                onEntered: {
                    if (toggle_im) {
                        oldcolor = toggle_m.palette.button
                        toggle_m.palette.button = TStyle.indicator_hovered
                    }
                }
                onExited: {
                    if (toggle_im) {
                        toggle_m.palette.button = oldcolor
                    }
                }
                onPressed: {
                    if (toggle_im) {
                        toggle_im = false
                        toggle_i.palette.button = TStyle.indicator
                        toggle_m.palette.dark = TStyle.indicator_pressed
                    }
                }
            }
        }
    }
}
