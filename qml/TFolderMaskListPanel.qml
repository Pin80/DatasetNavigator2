import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles  1.4
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel  2.0
import GlobalProp 1.0
import ipc.zmq 1.0

Item {
    id: control
    signal indicon();
    property alias modelfolder: folderMaskModel.folder
    property alias mmodel : folderMaskModel
    property string mskdialog_title: "intro"
    property string mskdialog_fname: "qrc:///images/intro.png"
    FolderListModel {
        id: folderMaskModel
        //nameFilters: ["*.*"]
        nameFilters: ["*.bmp", "*.jpg", "*.png", "*.gif"]
        folder: "~/"
        showDirs: false
    }
    Image {
        anchors.fill: parent
        fillMode: Image.Tile
        source: "qrc:///images/image_mlist.png"
        TImgDialog {
            id : mskdialog
            property int imgwidth: 350*TStyle.scalekx
            property int imgheight: 350*TStyle.scaleky
            iwidth: imgwidth
            iheight: imgheight
            title: control.mskdialog_title
            fname: control.mskdialog_fname
        }
        ScrollView {
            id: flickableMask
            anchors.fill: parent
            anchors.rightMargin: 20*TStyle.scalekx
            focus: true
            ScrollBar.vertical: TScrollBar {
                id: lmscrollbar
                parent: flickableMask.parent
                anchors.top: flickableMask.top
                anchors.left: flickableMask.right
                anchors.bottom: flickableMask.bottom
                sbwidth: flickableMask.anchors.rightMargin - 4
            }

            ListView {
                id: lview_mask
                anchors.fill: parent
                clip: true
                highlightFollowsCurrentItem: true
                Keys.onUpPressed: lview_mask.decrementCurrentIndex() //перемещение стрелками
                Keys.onDownPressed: lview_mask.incrementCurrentIndex() //перемещение стрелками

                model: folderMaskModel
                delegate: fileDelegate_mask
                onCountChanged: {
                    //maskboxChanged()
                }
                Component {
                    id: fileDelegate_mask
                    TDelegate_msk {
                        id: mfileDelegate_rec
                        delegfnameM: fileName
                        property string currdelegfname: ListView.isCurrentItem ? delegfnameM: ""
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
                        onShowMask: {
                            if (delegfnameM == "") {
                                mskialog_title = "intro"
                                mskdialog_fname = "qrc:///images/intro.png"
                            }
                            else {
                                control.mskdialog_title = delegfnameM
                                control.mskdialog_fname = "image://mcolors/" + mskdialog_title
                            }
                            mskdialog.show()
                        }
                        onCvtNames: {
                            Tipcagent.convertMaskFiles();
                            indicon();
                        }
                        MouseArea{
                            anchors.fill: parent
                            hoverEnabled: true
                            propagateComposedEvents: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            property string oldcolor: ""
                            onEntered: {
                                ishovered = true
                            }
                            onExited: {
                                ishovered = false
                            }
                            onPressed:      {
                                oldcolor = TStyle.list_select
                                if (mouse.button === Qt.RightButton) {
                                    if (typeof(mctxMenu) !== "undefined")
                                        mctxMenu.popup()
                                }
                                else {
                                    lview_mask.currentIndex = index
                                }
                            }
                        }
                        onCurrdelegfnameChanged: {
                            if (ListView.isCurrentItem) {
                                if (currdelegfname == "") {
                                    mskdialog_title = "intro"
                                    mskdialog_fname = "qrc:///images/intro.png"
                                }
                                else {
                                    mskdialog_title = currdelegfname
                                    mskdialog_fname = "image://mcolors/" + mskdialog_title
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

