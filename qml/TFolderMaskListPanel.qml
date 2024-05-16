import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel  2.0
import ipc.zmq 1.0

Rectangle {
    id: rectM
    color: "darkslateblue"
    border.color: "black"
    border.width: 2
    radius: 10
    property alias modelfolder: folderMaskModel.folder
    property alias mmodel : folderMaskModel
    FolderListModel {
        id: folderMaskModel
        //nameFilters: ["*.*"]
        nameFilters: ["*.bmp", "*.jpg", "*.png", "*.gif"]
        folder: "~/"
        showDirs: false
    }
    ScrollView {
        id: flickableMask
        anchors.fill: parent
        anchors.rightMargin: 20
        focus: true
        ScrollBar.vertical: ScrollBar {
            id: scrollBarMask
            parent: flickableMask.parent
            anchors.top: flickableMask.top
            anchors.left: flickableMask.right
            anchors.bottom: flickableMask.bottom
            width: 20
        }
    }
    ListView {
        id: lview_mask
        anchors.fill: parent
        anchors.topMargin: 5
        anchors.leftMargin: 5
        Layout.rightMargin: 5
        clip: true

        highlightFollowsCurrentItem: true
        Keys.onUpPressed: lview_mask.decrementCurrentIndex() //перемещение стрелками
        Keys.onDownPressed: lview_mask.incrementCurrentIndex() //перемещение стрелками
        Component {
            id: fileDelegate_mask
            Rectangle{
                id: itembox_mask
                property string delegfnameM: fileName
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 5
                anchors.rightMargin: 15
                height: 25
                border.color: "blue"
                border.width: 1
                property string calcincolor: (index%2 == 0)? "lightblue": "lightgreen"
                color: ListView.isCurrentItem ? "yellow" : calcincolor

                MouseArea{
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: {
                        if (mouse.button === Qt.RightButton) {

                        }
                        else {
                            lview_mask.currentIndex = index
                        }
                    }
                }
                RowLayout{
                    id: litem_rlayM
                    anchors.fill: parent
                    Text {
                        id: litem_textM
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        font.pointSize: 14
                        Layout.alignment: Qt.AlignVCenter
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        text: delegfnameM
                    }
                }
            }
        }
        model: folderMaskModel
        delegate: fileDelegate_mask
        onCountChanged: {
            //maskboxChanged()
        }
    }
}

