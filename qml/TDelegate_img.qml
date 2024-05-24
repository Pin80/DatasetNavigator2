import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles  1.4
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel  2.12
import GlobalProp 1.0

Rectangle{
    property alias delegfname: litem_text.text
    property alias currchecked : maskbox.checked
    signal checkMaskTest()
    signal findMask()
    signal showImage()
    signal cvtNames()
    property var ctxMenu : contextMenu
    //https://bugreports.qt.io/browse/QTBUG-106645
    border.color: TStyle.background_border
    border.width: 1

    property bool ishovered : false
    TContextMenu {
        id: contextMenu
        Action { text: qsTr("Show image"); onTriggered: showImage() }
        Action { text: qsTr("Find mask image file"); onTriggered: findMask() }
        Action { text: qsTr("Convert all file names"); onTriggered: cvtNames() }
    }

    RowLayout{
        id: litem_rlay
        anchors.fill: parent
        Text {
            id: litem_text
            Layout.leftMargin: font.pointSize
            font.pointSize: TStyle.scaleky*12
            color: TStyle.list_text
            Layout.alignment: Qt.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        CheckBox {
            id: maskbox
            Layout.alignment: Qt.AlignRight
            Layout.rightMargin: litem_text.height
            Layout.fillHeight: true
            indicator.height: litem_text.height - 4
            Layout.maximumWidth: litem_text.height
            Component.onCompleted: checkMaskTest();
        }

    }
}
