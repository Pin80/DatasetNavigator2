import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles  1.4
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel  2.12

Rectangle{
    id: itembox
    property alias delegfname: litem_text.text
    property alias currchecked : maskbox.checked
    signal checkMaskTest()
    signal findMask()
    property var ctxMenu : contextMenu
    //https://bugreports.qt.io/browse/QTBUG-106645
    readonly property real scalekx: (Screen.desktopAvailableWidth/1920)
    readonly property real scaleky: (Screen.desktopAvailableHeight/1080)
    property int imgwidth: 350*scalekx
    property int imgheight: 350*scaleky
    border.color: "blue"
    border.width: 1
    property string imgdialog_title: "intro"
    property string imgdialog_fname: "qrc:///images/intro.png"
    property bool ishovered : false
    TImgDialog {
        id : imgdialog
        iwidth: itembox.imgwidth
        iheight: itembox.imgheight
        title: imgdialog_title
        fname: imgdialog_fname
    }
    Menu {
        id: contextMenu
        MessageDialog {
            id: messageDialog_mask
            title: "Info"
            text: "Mask is not found"
            icon: StandardIcon.Critical
            Component.onCompleted: visible = false
        }
        MenuItem {
            id: ctxMenuItem_ishow
            text: "show"
            background: Rectangle {
                color: ctxMenuItem_ishow.hovered?"yellow":"pink"
            }
            onClicked:  imgdialog.show()
        }
        MenuItem {
            id: ctxMenuItem_check
            text: "find mask"
            background: Rectangle {
                color: ctxMenuItem_check.hovered?"yellow":"pink"
            }
            onClicked:  findMask()
        }
    }

    RowLayout{
        id: litem_rlay
        anchors.fill: parent
        Text {
            id: litem_text
            Layout.leftMargin: font.pointSize
            font.pointSize: scaleky*12
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
