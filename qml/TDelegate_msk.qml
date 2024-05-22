import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel  2.0

Rectangle{
    id: itembox_mask
    property alias delegfnameM: litem_textM.text
    border.color: "blue"
    border.width: 1
    property bool ishovered : false
    readonly property real scalekx: (Screen.desktopAvailableWidth/1920)
    readonly property real scaleky: (Screen.desktopAvailableHeight/1080)
    RowLayout{
        id: litem_rlayM
        anchors.fill: parent
        Text {
            id: litem_textM
            Layout.rightMargin: font.pointSize
            Layout.leftMargin: font.pointSize
            font.pointSize: scaleky*14
            Layout.alignment: Qt.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
    }
}
