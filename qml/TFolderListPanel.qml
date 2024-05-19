import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel  2.12
import QtQuick.Window 2.12
import ipc.zmq 1.0

Rectangle {
    id: rectI
    color: "darkcyan"
    border.color: "black"
    border.width: 2
    radius: 10
    signal maskboxChanged();
    property real scalekx: (Screen.desktopAvailableWidth/1920)
    property real scaleky: (Screen.desktopAvailableHeight/1080)
    property int imgwidth: 350*scalekx
    property int imgheight: 350*scaleky
    property string imgdialog_title: "intro"
    property string imgdialog_fname: "qrc:///images/intro.png"
    property string maskfolder: ""
    property alias imodel: folderModel
    property alias modelfolder: folderModel.folder
    property alias ilview : lview
    Image {
        anchors.fill: parent
        fillMode: Image.Tile
        source: "qrc:///images/image.png"
    FolderListModel {
        id: folderModel
        //nameFilters: ["*.*"]
        nameFilters: ["*.bmp", "*.jpg", "*.png", "*.gif"]
        folder: "~/"
        showDirs: false
        property int newcount : count
        onNewcountChanged: {
            if (folderModel.count <= 0) {
                imgdialog_title.title = "intro"
                imgdialog_fname.fname = "qrc:///images/intro.png"
            }
        }
    }
        ScrollView {
            id: flickable
            anchors.fill: parent
            anchors.rightMargin: 20*scalekx
            focus: true
            ScrollBar.vertical: ScrollBar {
                id: scrollBar
                parent: flickable.parent
                anchors.top: flickable.top
                anchors.left: flickable.right
                anchors.bottom: flickable.bottom
                width: flickable.anchors.rightMargin
                //anchors.rightMargin: 10 * AppTheme.scaleValue
                contentItem: Rectangle {
                    id: polzunok_img
                    implicitWidth: 6
                    color: "brown"
                    radius: 10
                    onHeightChanged: {
                        height = (height < 20*scalekx)? 20*scalekx:height
                    }
                    MouseArea {
                        propagateComposedEvents: true
                        anchors.fill: parent
                        onWheel:        { wheel.accepted = false; }
                        onPressed:      { mouse.accepted = false; }
                        onReleased:     { mouse.accepted = false; }
                        hoverEnabled: true
                        onEntered: polzunok_img.color = "pink"
                        onExited: polzunok_img.color = "brown"
                    }
                }
            }
            ListView {
                id: lview
                anchors.fill: parent
                anchors.topMargin: 3
                anchors.leftMargin: 3
                clip: true
                highlightFollowsCurrentItem: true
                Keys.onUpPressed: lview.decrementCurrentIndex() //перемещение стрелками
                Keys.onDownPressed: lview.incrementCurrentIndex() //перемещение стрелками
                property bool currentMaskFound: true
                //property string newfolder: folderModel.folder
                Component {
                    id: fileDelegate
                    Rectangle{
                        id: itembox
                        property string delegfname: fileName
                        property string curdelegfname: ListView.isCurrentItem ? delegfname: ""
                        property alias currchecked : maskbox.checked
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 3*(height/25)
                        anchors.rightMargin: 3*(height/25)
                        height: rectI.scaleky*25
                        border.color: "blue"
                        border.width: 1
                        property string calcincolor: (index%2 == 0)? "lightblue": "lightgreen"
                        color: ListView.isCurrentItem ? "yellow" : calcincolor
                        onCurdelegfnameChanged: {
                            if (ListView.isCurrentItem) {
                                if (curdelegfname == "") {
                                    imgdialog_title = "intro"
                                    imgdialog_fname = "qrc:///images/intro.png"
                                }
                                else {
                                    imgdialog_title = curdelegfname
                                    imgdialog_fname = "image://colors/" + imgdialog_title
                                }
                            }
                        }
                        TImgDialog {
                            id : imgdialog
                            iwidth: rectI.imgwidth
                            iheight: rectI.imgheight
                            title: imgdialog_title
                            fname: imgdialog_fname
                        }
                        MessageDialog {
                            id: messageDialog_notsend
                            title: "Error"
                            text: "Data is not sent"
                            icon: StandardIcon.Critical
                            Component.onCompleted: visible = false
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
                                onClicked:
                                    imgdialog.show()
                            }
                            MenuItem {
                                id: ctxMenuItem_check
                                text: "find mask"
                                background: Rectangle {
                                    color: ctxMenuItem_check.hovered?"yellow":"pink"
                                }
                                onClicked: {
                                    if (typeof modelmask !== "undefined") {
                                            var mname = Tipcagent.getshortMaskName(fileName,  maskfolder)
                                            if (mname.length !== 0) {
                                                var res = modelmask.indexOf(mname)
                                                maskbox.checked = (res !== -1)
                                                res = modelmask.get(0,"fileName")
                                            }
                                            else {
                                                maskbox.checked = false
                                            }
                                    }
                                    else {
                                        maskbox.checked = false
                                    }
                                }
                            }
                        }
                        MouseArea{
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: {
                                if (mouse.button === Qt.RightButton) {
                                    contextMenu.popup()
                                }
                                else {
                                    lview.currentIndex = index
                                    //btn_bind.enabled = true
                                }
                            }
                            onDoubleClicked: {
                                var res = Tipcagent.sendString(delegfname,
                                                     modelfolder,
                                                     maskfolder,
                                                     maskbox.checked);
                                if (!res)
                                    messageDialog_notsend.open()
                            }
                        }
                        RowLayout{
                            id: litem_rlay
                            anchors.fill: parent
                            Text {
                                id: litem_text
                                Layout.leftMargin: font.pointSize
                                font.pointSize: rectI.scaleky*14
                                Layout.alignment: Qt.AlignVCenter
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                text: delegfname
                            }
                            CheckBox {
                                id: maskbox
                                Layout.alignment: Qt.AlignVCenter
                                Layout.rightMargin: 5
                                Layout.fillHeight: true
                                indicator.width: indicator.height
                                indicator.height: height - 7
                                function testMask() {
                                    if (typeof modelmask !== "undefined") {
                                            var mname = Tipcagent.getshortMaskName(fileName,  maskfolder)
                                            if (mname.length !== 0) {
                                                var res = modelmask.indexOf(mname)
                                                return  (res !== -1)
                                            }
                                            else {
                                                maskbox.checked = false
                                                return false
                                            }
                                    }
                                    else {
                                        maskbox.checked = false
                                        return false
                                    }
                                }

                                Component.onCompleted: {
                                    checked = testMask()
                                }
                            }
                        }
                    }
                } // Component
                model: folderModel
                delegate: fileDelegate
            } // ListView
        } // ScrollView
    }
} //Rectangle
