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

Item {
    id : toggle_panel
    property bool toggle_im: true
    property alias isBound: zswitch.isBound
    signal sig_bind()
    signal sig_unbind()
    RowLayout {
        anchors.fill: parent
        spacing: 2
        anchors.margins: 2
        TSwitch {
            id: zswitch
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            text: qsTr("Connect")
            property alias isBound: zswitch.checked
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
                        zswitch.ishovered = true;
                }
                onExited: {
                    zswitch.ishovered = false;
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
            ispressed: toggle_im
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    if (!toggle_im) {
                        toggle_i.ishovered = true
                    }
                    else
                    {
                        toggle_i.ishovered = false
                    }
                }
                onExited: {
                    if (!toggle_im) {
                        toggle_i.ishovered = false
                    }
                    else
                    {
                        toggle_i.ishovered = false
                    }
                }
                onPressed: {
                    if (!toggle_im) {
                        toggle_im = true
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
            ispressed: !toggle_im
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    if (toggle_im) {
                        toggle_m.ishovered = true
                    }
                    else
                    {
                        toggle_m.ishovered = false
                    }
                }
                onExited: {
                    if (toggle_im) {
                        toggle_m.ishovered = false
                    }
                    else
                    {
                        toggle_m.ishovered = false
                    }
                }
                onPressed: {
                    if (toggle_im) {
                        toggle_im = false
                    }
                }
            }
        }
    }
}
