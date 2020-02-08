import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel 2.0
import ipc.zmq 1.0

ApplicationWindow {
    id: mainapp
    visible: true
    width: 320
    height: 480
    color: "brown"
    signal maskboxChanged();
    title: qsTr("Dataset Navigator")
    ColumnLayout{
        spacing: 1
        anchors.fill: parent
        anchors.margins: 10
        FolderListModel {
            id: folderMaskModel
            //nameFilters: ["*.*"]
            nameFilters: ["*.bmp", "*.jpg", "*.png", "*.gif"]
            folder: "~/"
            showDirs: true
        }
        FolderListModel {
            id: folderModel
            //nameFilters: ["*.*"]
            nameFilters: ["*.bmp", "*.jpg", "*.png", "*.gif"]
            folder: "~/"
            showDirs: false
        }
        ListView {
            id: lview_mask
            Component {
                id: fileDelegate_mask
                Rectangle{
                    id: itembox_mask
                    visible: false
                    property string fname: fileName
                    MouseArea{
                        anchors.fill: parent
                    }
                }
            }
            model: folderMaskModel
            delegate: fileDelegate_mask
            onCountChanged: {
                maskboxChanged()
            }
        }

        TButton {
            id: btn_selectdir
            text: "Choose Image Folder"
            TFileDialog {
                id: dirdialog_orig
                onAccepted: {
                    //console.log("btn_selectdir");
                    folderModel.folder = folder
                    dirdialog_orig.close()
                    flickable.focus = true
                }
            }
            onClicked: {
                dirdialog_orig.title = "Please choose a image folder"
                dirdialog_orig.folder = "/home/user/MySoftware/foreign code/netology_JN/Diplom/"
                dirdialog_orig.open()
                //console.log("Button Pressed. Entered text: ");
            }
        }
        TButton {
            id: btn_selectmdir
            text: "Choose Mask Image Folder"
            TFileDialog {
                id: dirmdialog
                onAccepted: {
                    //console.log("btn_selectdir");
                    folderModel.folder = dirdialog_orig.folder
                    folderMaskModel.folder = folder

                    console.log(folder)
                    dirmdialog.close()
                }
            }
            onClicked: {
                dirmdialog.title = "Please choose a mask folder"
                //dirmdialog.folder = "/home/user/MySoftware/foreign code/netology_JN/Diplom/"
                dirmdialog.open()
                //console.log("Button Pressed. Entered text: ");
            }
        }
        TButton {
            id: btn_bind
            property bool isBound: false
            text: "Bind Port"
            TMsgDialog {
                id : errordialog
                onAccepted: {
                    //console.log("btn_bind")
                    //Qt.quit()
                }
            }
            function onUnboundSocket() {
                //console.log("btn changed")
                btn_bind.isBound = false
                btn_bind.text = "Bind Port"
                btn_bind.enabled = true
                mainapp.update()
                sbartxt.text = "socket is unbound"
            }

            function onBoundSocket() {
                //console.log("btn changed")
                btn_bind.isBound = true
                btn_bind.text = "Unbind Port"
                btn_bind.enabled = true
                mainapp.update()
                sbartxt.text = "socket is bound"
            }
            onClicked: {
                //console.log("Button Pressed.");
                var result = false
                enabled = false
                if (isBound) {
                    result = Tipcagent.unbindSocket()
                    if (result) {
                       // Do Nothing
                    }
                    else
                    {
                        errordialog.open()
                        enabled = true
                    }
                }
                else {
                    result = Tipcagent.bindSocket(urledit.text)
                    if (result) {
                        // Do Nothing
                    }
                    else
                    {
                        errordialog.open()
                        enabled = true
                    }
                }
            }
        }
        TLineEdit{
            id: urledit
            text: "127.0.0.1:5561"
        }
        TLineEdit{
            id: prefixedit
            color: "lightgreen"
            text: "mask_"
        }
        Rectangle {
            Layout.alignment: Qt.AlignRight
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "green"
            border.color: "black"
            border.width: 2
            radius: 10
            Layout.preferredHeight: 40
            Layout.preferredWidth: 40
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
                        Component {
                            id: fileDelegate
                            Rectangle{
                                id: itembox
                                property string fname: fileName
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.margins: 0
                                height: 25
                                border.color: "blue"
                                border.width: 1
                                property string calcincolor: (index%2 == 0)? "lightblue": "lightgreen"
                                color: ListView.isCurrentItem ? "yellow" : calcincolor
                                MouseArea{
                                    anchors.fill: parent
                                    onClicked: {
                                        lview.currentIndex = index
                                        btn_bind.enabled = true
                                    }
                                    onDoubleClicked: {
                                        Tipcagent.sendString(fname,
                                                             folderModel.folder,
                                                             dirmdialog.folder,
                                                             prefixedit.text,
                                                             "photo",
                                                             maskbox.checked);
                                        //console.log("fname")
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
                                        text: fname
                                    }
                                    CheckBox {
                                        id: maskbox
                                        property string fnameC: fname
                                        Layout.alignment: Qt.AlignVCenter
                                        Layout.rightMargin: 5
                                        Layout.fillHeight: true
                                        indicator.width: 16
                                        indicator.height: 16
                                        checked: Tipcagent.foundMaskName(fileName,
                                                               dirmdialog.folder,
                                                               prefixedit.text,
                                                               "photo")
                                        signal mchanged();
                                        function onMchanged()
                                        {
                                            if (typeof fname != "undefined")
                                            {
                                                checked = Tipcagent.foundMaskName(fname,
                                                                                  dirmdialog.folder,
                                                                                  prefixedit.text,
                                                                                  "photo")
                                            }
                                            //console.log("+")
                                        }
                                        Component.onCompleted: {
                                            mainapp.maskboxChanged.connect(maskbox.onMchanged)
                                        }
                                    }
                                }
                            }
                        }
                        model: folderModel
                        delegate: fileDelegate
                    }
                } // ScrollView
        } //Rectangle
        Rectangle {
            id : statusbar
            Layout.alignment: Qt.AlignRight
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            Layout.preferredWidth: 40
            border.color: "black"
            border.width: 1
            color: "gray"
            Text {
                id: sbartxt
                anchors.fill: parent
                anchors.margins: 5
                focus: true
                font.family: "Helvetica"
                font.pointSize: 14
                text: "socket is unbound"
                color: "black"
            }
        }
    } //ColumnLayout
    Connections {
        target: Tipcagent
        onBoundSocket: btn_bind.onBoundSocket()
    }
    Connections {
        target: Tipcagent
        onUnboundSocket: btn_bind.onUnboundSocket()
    }
} //ApplicationWindow
