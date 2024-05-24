import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles  1.4
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel  2.0
import GlobalProp 1.0

Rectangle{
    property alias delegfnameM: litem_textM.text
    border.color: TStyle.background_border
    border.width: 1
    property bool ishovered : false
    RowLayout{
        id: litem_rlayM
        anchors.fill: parent
        Text {
            id: litem_textM
            Layout.rightMargin: font.pointSize
            Layout.leftMargin: font.pointSize
            font.pointSize: TStyle.scaleky*14
            Layout.alignment: Qt.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: TStyle.list_text
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
    }
}
