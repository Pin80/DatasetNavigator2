import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel  2.0
import QtQuick.Window 2.12
import Qt.labs.platform 1.1
import ipc.zmq 1.0


Window {
    id: mainapp
    visible: true
    readonly property real scalekx: (Screen.desktopAvailableWidth/1920)
    readonly property real scaleky: (Screen.desktopAvailableHeight/1080)
    width: scalekx*320
    height: scaleky*480
    color: "green"
    title: qsTr("Dataset Navigator")
    //console.log(folder)
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
            onSig_bind: { 
                Tipcagent.sig_bindSocket()
            }
            onSig_unbind: {
                Tipcagent.sig_unbindSocket()
            }

            function onUnboundSocket(result) {
                if (result) {
                    isBound = false
                    sbartxt.text = "socket is unbound"
                }
            }

            function onBoundSocket(result) {
                if (result) {
                    isBound = true
                    sbartxt.text = "socket is bound"
                }
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
        SwipeView {
            id: swipelist
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredHeight: scaleky*40
            currentIndex: togglepanel.toggle_im ? 0: 1
            onCurrentIndexChanged: {
                togglepanel.toggle_im = (currentIndex == 0)? true: false
            }

            TFolderListPanel {
                id: folderlistpanel
                objectName: "folderlistpanel" // unused
                //property var modelmask: foldermasklistpanel.mmodel
                onCheckMaskTest: {
                    if (typeof foldermasklistpanel.mmodel !== "undefined") {
                            var mname = Tipcagent.getshortMaskName(curdelegfname,
                                                                   foldermasklistpanel)
                            if (mname.length !== 0) {
                                var res = foldermasklistpanel.mmodel.indexOf(mname)
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
                onFindMask: {
                    console.log("attemt to find mask")
                    if (typeof foldermasklistpanel.mmodel !== "undefined") {
                            var mname = Tipcagent.getshortMaskName(curdelegfname,
                                                                   foldermasklistpanel.modelfolder)
                            if (mname.length !== 0) {
                                var res = foldermasklistpanel.mmodel.indexOf(mname)
                                currchecked = (res !== -1)
                                res = foldermasklistpanel.mmodel.get(0,"fileName")
                            }
                            else {
                                currchecked = false
                            }
                    }
                    else {
                        currchecked = false
                    }
                }
                MessageDialog {
                    id: messageDialog_notsend
                    title: "Error"
                    text: "Data is not sent"
                    //icon: StandardIcon.Critical
                    Component.onCompleted: visible = false
                }
                onSendMessage: {
                    var res = Tipcagent.sendString(curdelegfname,
                                         modelfolder,
                                         foldermasklistpanel.modelfolder,
                                         currchecked);
                    if (!res)
                        messageDialog_notsend.open()
                }

            }
            TFolderMaskListPanel {
                id: foldermasklistpanel
            }
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
        var urlfolder =  Tipcagent.folder
        fldbtnpanel.panel_folder = urlfolder
        console.log("default folder:", urlfolder )
        urlfolder = Tipcagent.maskfolder
        fldbtnpanel.panel_maskfolder = urlfolder
        console.log("default mfolder:", urlfolder )

    }

} //ApplicationWindow
