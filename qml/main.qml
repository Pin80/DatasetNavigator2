import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import QtQuick.Window 2.12
import Qt.labs.platform 1.1
import ipc.zmq 1.0
import GlobalProp 1.0

ApplicationWindow {
    id: mainapp
    visible: true
    width: TStyle.scalekx*320
    height: TStyle.scaleky*480
    minimumWidth: TStyle.scalekx*320
    minimumHeight: TStyle.scalekx*240
    color: TStyle.background
    title: qsTr("Dataset Navigator")
    signal maskboxChanged();
    onClosing: {
        Tipcagent.closeWindow()
    }
    Image {
        anchors.fill: parent
        fillMode: Image.Tile
        source: TStyle.background_tex
        Popup {
            id: popupwnd
            anchors.centerIn: parent
            closePolicy: Popup.NoAutoClose
            modal: true
            focus: true
            visible: pactivate
            parent: mainapp.contentItem
            property bool pactivate: false
            TBusyIndicator {
                id: busyindic
                running: popupwnd.pactivate
                anchors.fill: parent
                anchors.centerIn: parent
                width: 100*TStyle.scalekx
                height: 100*TStyle.scalekx
            }
        }
        ColumnLayout {
            spacing: 2
            anchors.margins: 2
            anchors.fill: parent
            TFolderButtonPanel {
                id: fldbtnpanel
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop
                Layout.preferredHeight: TStyle.scaleky*60
                Layout.maximumHeight: TStyle.scaleky*120
                onPanel_folderChanged: {
                    popupwnd.pactivate = true
                    folderlistpanel.modelfolder = panel_folder
                    Tipcagent.folder = panel_folder
                    popupwnd.pactivate = false
                }
                onPanel_maskfolderChanged: {
                    popupwnd.pactivate = true
                    Tipcagent.maskfolder = panel_maskfolder
                    foldermasklistpanel.modelfolder = panel_maskfolder
                    var ifolder = folderlistpanel.modelfolder
                    folderlistpanel.modelfolder = "./none"
                    folderlistpanel.modelfolder = ifolder
                    popupwnd.pactivate = false
                }
                onUpdatelists: {
                    popupwnd.pactivate = true
                    console.log("update")
                    var ifolder = folderlistpanel.modelfolder
                    var mfolder = foldermasklistpanel.modelfolder
                    folderlistpanel.modelfolder = "./none"
                    folderlistpanel.modelfolder = ifolder
                    popupwnd.pactivate = false
                }
            }
            TTogglePanel {
                id: togglepanel
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop
                Layout.preferredHeight: TStyle.scaleky*20
                Layout.maximumHeight: TStyle.scaleky*30
                Layout.minimumHeight: TStyle.scaleky*30
                onSig_bind: {
                    popupwnd.pactivate = true
                    Tipcagent.sig_bindSocket()
                }
                onSig_unbind: {
                    popupwnd.pactivate = true
                    Tipcagent.sig_unbindSocket()
                }

                function onUnboundSocket(result) {
                    if (result) {
                        isBound = false
                        sbartxt.text = qsTr("socket is unbound")
                    }
                    popupwnd.pactivate = false
                }

                function onBoundSocket(result) {
                    if (result) {
                        isBound = true
                        sbartxt.text = qsTr("socket is bound")
                    }
                    popupwnd.pactivate = false
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
            }
            SwipeView {
                id: swipelist
                Layout.alignment: Qt.AlignTop
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredHeight: TStyle.scaleky*40
                currentIndex: togglepanel.toggle_im ? 0: 1
                onCurrentIndexChanged: {
                    togglepanel.toggle_im = (currentIndex == 0)? true: false
                }

                TFolderListPanel {
                    id: folderlistpanel
                    objectName: "folderlistpanel" // unused
                    maskmodel: foldermasklistpanel.mmodel;
                    onIndicon: popupwnd.pactivate = true
                    TMsgDialog {
                        id: messageDialog_cvtres
                        title: "Info"
                        text: "Operation is compleated. \n See  report.txt"
                        icon: StandardIcon.Information
                        Component.onCompleted: visible = false
                    }
                    Connections {
                        target: Tipcagent
                        onConverted: {
                            console.log("converted:", result)
                            var infostr = "Operation is compleated. \n";
                                infostr = infostr + "renamed: "  + result + " files\n"
                                infostr = infostr + " See  report.txt"
                            messageDialog_cvtres.text = infostr
                            popupwnd.pactivate = false
                            messageDialog_cvtres.open()
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
                            popupwnd.pactivate = false
                        }
                    }
                    Connections {
                        target: Tipcagent
                        onSentString :{
                            popupwnd.pactivate = false
                        }
                    }
                }
                TFolderMaskListPanel {
                    onIndicon: popupwnd.pactivate = true
                    id: foldermasklistpanel
                }
            }

            Rectangle {
                id : statusbar
                Layout.alignment: Qt.AlignBottom
                Layout.fillWidth: true
                Layout.preferredHeight: TStyle.scaleky*30
                border.color: TStyle.background_border
                border.width: 1
                color: TStyle.background_small
                Text {
                    id: sbartxt
                    anchors.fill: parent
                    anchors.bottomMargin: 5
                    anchors.leftMargin: 5
                    focus: true
                    font.family: "Helvetica"
                    font.pointSize: 14*TStyle.scaleky
                    text: "socket is unbound"
                    color: "black"
                }
            }
        } //ColumnLayout
        Component.onCompleted: {
            x: Screen.desktopAvailableWidth - width
            y: Screen.desktopAvailableHeight/2 - height/2
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
    }
} //ApplicationWindow
