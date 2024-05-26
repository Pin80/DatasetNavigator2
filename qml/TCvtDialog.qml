import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.1
import Qt.labs.folderlistmodel  2.12
import GlobalProp 1.0

Dialog {
    id: control
    title: "Title"
    standardButtons: Dialog.Ok | Dialog.Cancel
    modal: true
    property alias resultval : spin.value
    property alias maxvalue : spin.to
    property alias minvalue : spin.from
    background: Rectangle {
        color: TStyle.background
        border.color: "black"
    }
    contentItem: Rectangle {
        color: TStyle.background
        implicitWidth: 400
        implicitHeight: 100
        ColumnLayout {
            anchors.fill: parent
            SpinBox {
                id: spin
                Layout.fillWidth: true
                value: 50
                editable: true
                background: Rectangle {
                    implicitWidth: 140
                    border.color: "#bdbebf"
                    color: TStyle.list_odd
                }
            }
        }
    }
}
