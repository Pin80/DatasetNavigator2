import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel  2.0
import QtQuick.Controls.Material 2.2
import QtQuick.Templates 2.2 as T

Item {
    id: togglepanel
    property bool toggle_im: true
    property bool isBound: false
    signal sig_bind()
    signal sig_unbind()
    RowLayout {
        anchors.fill: parent
        spacing: 2
        Switch {
            id: toggle_bind2
            text: qsTr("Connect")
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            Layout.preferredHeight: 30
            Layout.preferredWidth: 50
            checked: isBound
            TMsgDialog {
                id : errordialog2
            }

            indicator: Rectangle {
                id: indicswitch
                implicitWidth: 50
                implicitHeight: 26
                property color btn_color : "white"
                x: toggle_bind2.leftPadding
                y: parent.height / 2 - height / 2
                radius: 13
                color: toggle_bind2.checked ? "#17a81a" : "grey"
                border.color: toggle_bind2.checked ? "#17a81a" : "#cccccc"

                Rectangle {
                    id: indicswitchbtn
                    x: toggle_bind2.checked ? parent.width - width : 0
                    width: 26
                    height: 26
                    radius: 13
                    border.color: toggle_bind2.checked ? (toggle_bind2.down ? "#17a81a" : "#21be2b") : "#999999"
                }
            }

            contentItem: Text {
                text: toggle_bind2.text
                font: toggle_bind2.font
                opacity: enabled ? 1.0 : 0.3
                verticalAlignment: Text.AlignVCenter
                leftPadding: toggle_bind2.indicator.width + toggle_bind2.spacing
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                property color oldcolor : "grey"
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
                        indicswitchbtn.color = "mistyrose"
                }
                onExited: {
                        indicswitchbtn.color = oldcolor
                }
            }
        }
        TToggle {
            id: toggle_i
            text: qsTr("Im")

            checked: togglepanel.toggle_im
            checkable: !togglepanel.toggle_im
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            Layout.preferredHeight: 30
            Layout.preferredWidth: 20
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                property color oldcolor : "grey"
                onEntered: {
                    if (!togglepanel.toggle_im) {
                        oldcolor = toggle_i.palette.button
                        toggle_i.palette.button = "mistyrose"
                    }
                }
                onExited: {
                    if (!togglepanel.toggle_im) {
                        toggle_i.palette.button = oldcolor
                    }
                }
                onPressed: {
                    if (!togglepanel.toggle_im) {
                        togglepanel.toggle_im = true
                        toggle_i.palette.button = oldcolor
                    }
                }
             }
        }
        TToggle {
            id: toggle_m
            text: qsTr("Msk")
            checked: !togglepanel.toggle_im
            checkable: togglepanel.toggle_im
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            Layout.preferredHeight: 30
            Layout.preferredWidth: 20
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                property color oldcolor : "grey"
                onEntered: {
                    if (togglepanel.toggle_im) {
                        oldcolor = toggle_m.palette.button
                        toggle_m.palette.button = "mistyrose"
                    }
                }
                onExited: {
                    if (togglepanel.toggle_im) {
                        toggle_m.palette.button = oldcolor
                    }
                }
                onPressed: {
                    if (togglepanel.toggle_im) {
                        togglepanel.toggle_im = false
                        toggle_m.palette.button = oldcolor
                    }
                }
            }
        }
    }
}
