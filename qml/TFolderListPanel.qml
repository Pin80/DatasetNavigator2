import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel  2.12
import ipc.zmq 1.0

Rectangle {
    id: rectI
    color: "darkcyan"
    border.color: "black"
    border.width: 2
    radius: 10
    signal maskboxChanged();
    property int imgwidth: 350
    property int imgheight: 350
    property string imgdialog_title: "intro"
    property string imgdialog_fname: "qrc:///qml/intro.png"
    property string maskfolder: ""
    property alias imodel: folderModel
    property alias modelfolder: folderModel.folder
    property alias ilview : lview
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
                imgdialog_fname.fname = "qrc:///qml/intro.png"
            }
        }
    }
    ScrollView {
        id: flickable
        anchors.fill: parent
        anchors.rightMargin: 20
        focus: true
        ScrollBar.vertical: ScrollBar {
            id: scrollBar
            parent: flickable.parent
            anchors.top: flickable.top
            anchors.left: flickable.right
            anchors.bottom: flickable.bottom
            width: 20
        }
        ListView {
            id: lview
            anchors.fill: parent
            anchors.topMargin: 5
            anchors.leftMargin: 5
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
                    anchors.margins: 5
                    height: 25
                    border.color: "blue"
                    border.width: 1
                    property string calcincolor: (index%2 == 0)? "lightblue": "lightgreen"
                    color: ListView.isCurrentItem ? "yellow" : calcincolor
                    onCurdelegfnameChanged: {
                        if (ListView.isCurrentItem) {
                            if (curdelegfname == "") {
                                imgdialog_title = "intro"
                                imgdialog_fname = "qrc:///qml/intro.png"
                            }
                            else {
                                imgdialog_title = curdelegfname
                                imgdialog_fname = "image://colors/" + imgdialog_title
                            }
                        }
                    }
                    TImgDialog {
                        id : imgdialog
                        width: rectI.imgwidth
                        height: rectI.imgheight
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

                        //anchors.right: parent.right
                        //anchors.margins: 10
                        Text {
                            id: litem_text
                            Layout.leftMargin: 10
                            font.pointSize: 14
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            text: delegfname
                        }
                        CheckBox {
                            id: maskbox
                            property string fnameC: delegfname
                            Layout.alignment: Qt.AlignVCenter
                            Layout.rightMargin: 5
                            Layout.fillHeight: true
                            indicator.width: 16
                            indicator.height: 16
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
} //Rectangle
