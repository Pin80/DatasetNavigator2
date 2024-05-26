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
    signal sendImage()
    signal checkMaskTest()
    signal findMask()
    signal showImage()
    signal cvtNames()
    signal reindexNames()
    property var ctxMenu : mcontextMenu
    //https://bugreports.qt.io/browse/QTBUG-106645
    border.color: TStyle.background_border
    border.width: 1

    property bool ishovered : false
    TContextMenu {
        MenuSeparator {
            contentItem: Rectangle {
                implicitHeight: 1
                color: TStyle.background_small
            }
        }
        id: mcontextMenu
        Action { text: qsTr("Send to A.T."); onTriggered: sendImage() }
        Action { text: qsTr("Show image"); onTriggered: showImage() }
        Action { text: qsTr("Find mask image file"); onTriggered: findMask() }
        Action { text: qsTr("Fix all file names"); onTriggered: cvtNames() }
        Action { text: qsTr("Reindex all file names"); onTriggered: reindexNames() }
        MenuSeparator {
            contentItem: Rectangle {
                implicitHeight: 1
                color: TStyle.background_small
            }
        }
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
            palette.base: "transparent"
            Layout.alignment: Qt.AlignRight
            Layout.rightMargin: litem_text.height
            Layout.fillHeight: true
            indicator.height: litem_text.height - 4
            indicator.width: litem_text.height - 4
            Layout.maximumWidth: litem_text.height
            Component.onCompleted: checkMaskTest();
        }

    }
}
