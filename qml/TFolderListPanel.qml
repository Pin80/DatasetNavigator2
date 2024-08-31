import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles  1.4
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel  2.12
import ipc.zmq 1.0
import GlobalProp 1.0

Item {
    signal indicon();
    property alias imodel: folderModel
    property alias modelfolder: folderModel.folder
    property var maskmodel: undefined
    property alias ilview : lview
    property string imgdialog_title: "intro"
    property string imgdialog_fname: "qrc:///images/intro.png"
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
    Image {
        anchors.fill: parent
        fillMode: Image.Tile
        source: "qrc:///images/image_ilist.png"
        TImgDialog {
            id : imgdialog
            property int imgwidth: 350*TStyle.scalekx
            property int imgheight: 350*TStyle.scaleky
            iwidth: imgwidth
            iheight: imgheight
            title: imgdialog_title
            fname: imgdialog_fname
            x: Screen.desktopAvailableWidth/2 - imgwidth/2
            y: Screen.desktopAvailableHeight/2 - imgheight/2
        }
        TCvtDialog {
            id: cvtdialog
            width: 250
            height: 250
            minvalue: 1
            maxvalue: 10000
            title: "set start index"
            onAccepted: {
                console.log("select:", resultval )
                Tipcagent.reindexImageFiles(resultval);
            }
        }
        ScrollView {
            id: flickable
            anchors.fill: parent
            anchors.rightMargin: 20*TStyle.scalekx
            focus: true
            ScrollBar.vertical: TScrollBar {
                id: lscrollbar
                parent: flickable.parent
                anchors.top: flickable.top
                anchors.left: flickable.right
                anchors.bottom: flickable.bottom
                sbwidth: flickable.anchors.rightMargin - 4
            }
            ListView {
                id: lview
                anchors.fill: parent
                clip: true
                orientation: ListView.Vertical
                highlightFollowsCurrentItem: true
                Keys.onUpPressed: lview.decrementCurrentIndex() //перемещение стрелками
                Keys.onDownPressed: lview.incrementCurrentIndex() //перемещение стрелками
                property bool currentMaskFound: true
                delegate: ifileDelegate
                model: folderModel
                Component {
                    id: ifileDelegate
                    TDelegate_img {
                        id: ifileDelegate_rec
                        delegfname: fileName
                        property string currdelegfname: ListView.isCurrentItem ? delegfname: ""
                        signal sendMessage(string ifname);
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 0*(height/25)
                        anchors.rightMargin: 3*(height/25)
                        height: TStyle.scaleky*25
                        property string calcincolor: (index%2 == 0)? TStyle.list_odd: TStyle.list_even
                        property string currcolor: ListView.isCurrentItem ? TStyle.list_select : calcincolor
                        readonly property string currcolorH: TStyle.indicator_hovered
                        property string currcolorhov: ishovered ? currcolorH : currcolor
                        color: currcolorhov
                        onCheckMaskTest: {
                            if (typeof maskmodel !== "undefined") {
                                    var mname = Tipcagent.getshortMaskName(fileName,
                                                                           maskmodel.folder)
                                    if (mname.length !== 0) {
                                        var res = maskmodel.indexOf(mname)
                                        currchecked = (res !== -1)
                                    }
                                    else {
                                        currchecked = false
                                    }
                            }
                            else {
                                currchecked = false
                            }
                        }
                        TMsgDialog {
                            id: messageDialog_mask
                            title: "Info"
                            text: "Mask is not found"
                            icon: StandardIcon.Critical
                            Component.onCompleted: visible = false
                        }

                        onFindMask: {
                            console.log("attemt to find mask")
                            if (typeof maskmodel !== "undefined") {
                                    var mname = Tipcagent.getshortMaskName(fileName,
                                                                           maskmodel.folder)
                                    if (mname.length !== 0) {
                                        var res = maskmodel.indexOf(mname)
                                        currchecked = (res !== -1)
                                        if (!currchecked)
                                            messageDialog_mask.open()
                                        console.log("attemt to find mask", mname, "by image:", fileName, " result:",res)
                                        res = maskmodel.get(0,"fileName")
                                    }
                                    else {
                                        currchecked = false
                                        messageDialog_mask.open()
                                    }
                            }
                            else {
                                currchecked = false
                                messageDialog_mask.open()
                            }
                        }
                        onShowImage: {
                            if (delegfname == "") {
                                imgdialog_title = "intro"
                                imgdialog_fname = "qrc:///images/intro.png"
                            }
                            else {
                                imgdialog_title = delegfname
                                imgdialog_fname = "image://colors/" + imgdialog_title
                            }
                            imgdialog.show()
                        }
                        onCvtNames: {
                            indicon();
                            Tipcagent.convertImageFiles();
                        }
                        onReindexNames: {
                            cvtdialog.open()
                        }

                        MessageDialog {
                            id: messageDialog_notsend
                            title: "Error"
                            text: "Data is not sent"
                            icon: StandardIcon.Critical
                            Component.onCompleted: visible = false
                        }
                        onSendMessage: {
                                if (typeof maskmodel !== "undefined") {
                                    indicon();
                                    var res = Tipcagent.sendString(delegfname,
                                                         modelfolder,
                                                         maskmodel.folder,
                                                         currchecked);
                                    if (!res)
                                        messageDialog_notsend.open()
                                }
                        }

                        MouseArea {
                            property string oldcolor: ""
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            hoverEnabled: true
                            propagateComposedEvents: true
                            onDoubleClicked: sendMessage(currdelegfname)
                            onEntered: ishovered = true
                            onExited: ishovered = false
                            onPressed:      {
                                if (mouse.button === Qt.RightButton) {
                                    if (typeof(ctxMenu) !== "undefined")
                                        ctxMenu.popup()
                                }
                                else {
                                    lview.currentIndex = index
                                }
                                oldcolor = TStyle.list_select
                            }
                        }
                        onCurrdelegfnameChanged: {
                            if (ListView.isCurrentItem) {
                                if (currdelegfname == "") {
                                    imgdialog_title = "intro"
                                    imgdialog_fname = "qrc:///images/intro.png"
                                }
                                else {
                                    imgdialog_title = currdelegfname
                                    imgdialog_fname = "image://colors/" + imgdialog_title
                                }
                            }
                        }
                    }
                } // Component
            } // ListView
        } // ScrollView
    } // Image
} //Rectangle
