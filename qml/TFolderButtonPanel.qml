import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel  2.0
import ipc.zmq 1.0

Item {
    id: fldButtonPanel
    property string panel_folder: ""
    property string panel_maskfolder: ""
    signal updatelists();
    ColumnLayout {
        anchors.fill: parent
        spacing: 1
        anchors.margins: 2
        TButton {
            id: btn_selectdir
            text: "Choose Image Folder"
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            Layout.preferredHeight: 40
            Layout.preferredWidth: 40
            //bcolor: "#a8abe8"
            TFileDialog {
                id: dirdialog_orig
                onAccepted: {
                    panel_folder = folder
                    console.log("folder")
                    console.log(Tipcagent.folder)
                }
            }
            grad: grad1
            MouseArea {
                Gradient {
                    id: grad1
                     GradientStop {
                         id: grad1stop1
                         position: 0 ; color: btn_selectdir.pressed ? "#ccc" : "#eee"
                     }
                     GradientStop {
                         id: grad1stop2
                         position: 1 ; color: btn_selectdir.pressed ? "#aaa" : "#ccc"
                     }
                }
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    console.log("folder dialog called")
                    dirdialog_orig.title = "Please choose a image folder"
                    dirdialog_orig.folder = "/home/user"
                    dirdialog_orig.open()
                }
                onEntered: {
                    grad1stop1.color = btn_selectdir.pressed ? "#ccc" : "#ece"
                    grad1stop2.color = btn_selectdir.pressed ? "#aaa" : "#ccc"
                }
                onExited: {
                    grad1stop1.color = btn_selectdir.pressed ? "#ccc" : "#eee"
                    grad1stop2.color = btn_selectdir.pressed ? "#aaa" : "#ccc"
                }

            }
        }
        TButton {
            id: btn_selectmdir
            text: "Choose Mask Image Folder"
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            Layout.preferredHeight: 40
            Layout.preferredWidth: 40
            TFileDialog {
                id: dir_mdialogM
                onAccepted: {
                    panel_maskfolder = folder
                    dir_mdialogM.close()
                }
            }
            grad: grad2
            MouseArea {
                Gradient {
                    id: grad2
                     GradientStop {
                         id: grad2stop1
                         position: 0 ; color: btn_selectmdir.pressed ? "#ccc" : "#eee"
                     }
                     GradientStop {
                         id: grad2stop2
                         position: 1 ; color: btn_selectmdir.pressed ? "#aaa" : "#ccc"
                     }
                }
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    dir_mdialogM.title = "Please choose a mask folder"
                    dir_mdialogM.folder = "/home/user"
                    dir_mdialogM.open()
                }
                onEntered: {
                    grad2stop1.color = btn_selectmdir.pressed ? "#ccc" : "#ece"
                    grad2stop2.color = btn_selectmdir.pressed ? "#aaa" : "#ccc"
                }
                onExited: {
                    grad2stop1.color = btn_selectdir.pressed ? "#ccc" : "#eee"
                    grad2stop2.color = btn_selectdir.pressed ? "#aaa" : "#ccc"
                }

            }
        }
        TButton {
            id: btn_update
            text: "Update lists"
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            Layout.preferredHeight: 40
            Layout.preferredWidth: 40
            grad: grad3
            MouseArea {
                Gradient {
                    id: grad3
                     GradientStop {
                         id: grad3stop1
                         position: 0 ; color: btn_update.pressed ? "#ccc" : "#eee"
                     }
                     GradientStop {
                         id: grad3stop2
                         position: 1 ; color: btn_update.pressed ? "#aaa" : "#ccc"
                     }
                }
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    updatelists()
                }
                onEntered: {
                    grad3stop1.color = btn_update.pressed ? "#ccc" : "#ece"
                    grad3stop2.color = btn_update.pressed ? "#aaa" : "#ccc"
                }
                onExited: {
                    grad3stop1.color = btn_update.pressed ? "#ccc" : "#eee"
                    grad3stop2.color = btn_update.pressed ? "#aaa" : "#ccc"
                }

            }
        }
    }
}
