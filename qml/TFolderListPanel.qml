import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles  1.4
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel  2.12

Item {
    id: rectI
    signal maskboxChanged();
    signal checkMaskTest();
    signal findMask();
    signal sendMessage();
    property alias curdelegfname: lview._curdelegfname
    property alias currchecked : lview._currchecked
    readonly property real scalekx: (Screen.desktopAvailableWidth/1920)
    readonly property real scaleky: (Screen.desktopAvailableHeight/1080)
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
                ifileDelegate.imgdialog_title.title = "intro"
                ifileDelegate.imgdialog_fname.fname = "qrc:///images/intro.png"
            }
        }
    }
    Image {
        anchors.fill: parent
        fillMode: Image.Tile
        source: "qrc:///images/image_ilist.png"
        ScrollView {
            id: flickable
            anchors.fill: parent
            anchors.rightMargin: 20*scalekx
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
                property string _curdelegfname: curdelegfname
                property string _currchecked: currchecked
                delegate: ifileDelegate
                model: folderModel
                Component {
                    id: ifileDelegate
                    TDelegate_img {
                        id: ifileDelegate_rec
                        delegfname: fileName
                        property string curdelegfname: ListView.isCurrentItem ? delegfname: ""
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 0*(height/25)
                        anchors.rightMargin: 3*(height/25)
                        height: scaleky*25
                        property string calcincolor: (index%2 == 0)? "lightblue": "lightgreen"
                        property string currcolor: ListView.isCurrentItem ? "lightyellow" : calcincolor
                        readonly property string currcolorH: "yellow"
                        property string currcolorhov: ishovered ? currcolorH : currcolor
                        color: currcolorhov
                        onCheckMaskTest : rectI.checkMaskTest()
                        onFindMask: {
                            console.log("attemt to find mask")
                            rectI.findMask()
                        }
                        MouseArea {
                            property string oldcolor: ""
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            hoverEnabled: true
                            propagateComposedEvents: true
                            onDoubleClicked: sendMessage()
                            onEntered: ishovered = true
                            onExited: ishovered = false
                            onPressed:      {
                                if (mouse.button === Qt.RightButton) {
                                    ctxMenu.popup()
                                }
                                else {
                                    lview.currentIndex = index
                                }
                                oldcolor = "lightyellow"
                            }
                        }
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

                    }
                } // Component
            } // ListView
        } // ScrollView
    } // Image
} //Rectangle
