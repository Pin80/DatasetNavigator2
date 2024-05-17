import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel  2.0
import ipc.zmq 1.0
import QtQuick.Window 2.12
import Qt.labs.platform 1.1


ApplicationWindow {
    id: mainapp
    visible: true
    property real scalekx: (Screen.desktopAvailableWidth/1920)
    property real scaleky: (Screen.desktopAvailableHeight/1080)
    width: scalekx*320
    height: scaleky*480
    color: "brown"
    title: qsTr("Dataset Navigator")
    font.pixelSize: scaleky*14
    //console.log(folder)
    property bool toggle_im_state: true
    signal maskboxChanged();
    onClosing: {
        Tipcagent.closeWindow()
    }
    // Под Gnome не работает
    /*
    SystemTrayIcon {
        visible: true
        iconSource:  "qrc:/images/favicon_s.png"
        onActivated: {
            mainapp.show()
            mainapp.raise()
            mainapp.requestActivate()
        }
    }
    */
    ColumnLayout {
        spacing: 2
        anchors.margins: 2
        anchors.fill: parent
        TFolderButtonPanel {
            id: fldbtnpanel
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            Layout.preferredHeight: scaleky*60
            Layout.maximumHeight: scaleky*120
            onPanel_folderChanged: {
                folderlistpanel.modelfolder = panel_folder
                Tipcagent.folder = panel_folder
            }
            onPanel_maskfolderChanged: {
                folderlistpanel.maskfolder = panel_maskfolder
                Tipcagent.maskfolder = panel_folder
                foldermasklistpanel.modelfolder = panel_maskfolder
            }
            onUpdatelists: {
                console.log("update")
                var ifolder = folderlistpanel.modelfolder
                var mfolder = foldermasklistpanel.modelfolder
                folderlistpanel.modelfolder = "./none"
                folderlistpanel.modelfolder = ifolder
            }
        }
        TTogglePanel {
            id: togglepanel
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            Layout.preferredHeight: scaleky*20
            Layout.maximumHeight: scaleky*30
            Layout.minimumHeight: scaleky*30
            onToggle_imChanged: {
                toggle_im_state = toggle_im
            }
            onSig_bind: { 
                Tipcagent.sig_bindSocket()
            }
            onSig_unbind: {
                Tipcagent.sig_unbindSocket()
            }

            function onUnboundSocket(result) {
                if (result)
                    isBound = false
            }

            function onBoundSocket(result) {
                if (result)
                    isBound = true
            }
            Connections {
                target: Tipcagent
                onBoundSocket: {
                    console.log("qml connections slot is bound")
                    togglepanel.onBoundSocket(result)
                }
            }
            Connections {
                target: Tipcagent
                onUnboundSocket: {
                    console.log("qml connections slot is unbound")
                    togglepanel.onUnboundSocket(result)
                }
            }
            Connections {
                target: Tipcagent
                onRecvString: {
                    var res = folderlistpanel.imodel.indexOf(result)
                    if (res !== -1) {
                        if (res === folderlistpanel.ilview.currentIndex)
                        {
                            console.log("marked for recv:", result)
                            folderlistpanel.ilview.currentItem.currchecked = true
                        }
                    }
                }
            }
        }

        TFolderListPanel {
            id: folderlistpanel
            objectName: "folderlistpanel"
            visible: toggle_im_state
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredHeight: scaleky*40
            property var modelmask: foldermasklistpanel.mmodel
        }
        TFolderMaskListPanel {
            id: foldermasklistpanel
            visible: !toggle_im_state
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredHeight: scaleky*40
        }

        Rectangle {
            id : statusbar
            Layout.alignment: Qt.AlignBottom
            Layout.fillWidth: true
            Layout.preferredHeight: scaleky*30
            border.color: "black"
            border.width: 1
            color: "gray"
            Text {
                id: sbartxt
                anchors.fill: parent
                anchors.bottomMargin: 5
                anchors.leftMargin: 5
                focus: true
                font.family: "Helvetica"
                font.pointSize: 14*scaleky
                text: "socket is unbound"
                color: "black"
            }
        }
    } //ColumnLayout
    Component.onCompleted: {
        x = Screen.width / 2 - width / 2
        y = Screen.height / 2 - height / 2
        if (QT_DEBUG === false) {
            togglepanel.toggle_im = true
            Tipcagent.sig_bindSocket()
        }
    }
} //ApplicationWindow
