import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel  2.0
import QtGraphicalEffects 1.12

Item {
    id: fldButtonPanel
    property string panel_folder: ""
    property string panel_maskfolder: ""
    readonly property real scalekx: (Screen.desktopAvailableWidth/1920)
    readonly property real scaleky: (Screen.desktopAvailableHeight/1080)
    readonly property int fldButtonPanrlHeight: 120*scaleky
    signal updatelists();
    ColumnLayout {
        anchors.fill: parent
        spacing: 1
        anchors.margins: 2
        TButton_gradient {
            id: btn_selectdir
            text: "Image Folder"
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            Layout.preferredHeight: fldButtonPanrlHeight*0.35
            TFileDialog {
                id: dirdialog_orig
                onAccepted: {
                    panel_folder = folder
                    console.log("folder")
                    console.log(Tipcagent.folder)
                }
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    console.log("folder dialog called")
                    dirdialog_orig.title = "Please choose a image folder"
                    dirdialog_orig.folder = "/home/user"
                    dirdialog_orig.open()
                }
                onEntered: btn_selectdir.is_hovered = true;
                onExited:  btn_selectdir.is_hovered = false;
                onPressed: btn_selectdir.is_pressed = true;
                onReleased: btn_selectdir.is_pressed = false;

            }
        }
        TButton_gradient {
            id: btn_selectmdir
            text: "Mask Image Folder"
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            Layout.preferredHeight: fldButtonPanrlHeight*0.35
            TFileDialog {
                id: dir_mdialogM
                onAccepted: {
                    panel_maskfolder = folder
                    dir_mdialogM.close()
                }
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    dir_mdialogM.title = "Please choose a mask folder"
                    dir_mdialogM.folder = "/home/user"
                    dir_mdialogM.open()
                }
                onEntered: btn_selectmdir.is_hovered = true;
                onExited:  btn_selectmdir.is_hovered = false;
                onPressed: btn_selectmdir.is_pressed = true;
                onReleased: btn_selectmdir.is_pressed = false;
            }
        }
        TButton_gradient {
            id: btn_update
            text: "Update lists"
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            Layout.preferredHeight: fldButtonPanrlHeight*0.3
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    updatelists()
                }
                onEntered: btn_update.is_hovered = true;
                onExited:  btn_update.is_hovered = false;
                onPressed: btn_update.is_pressed = true;
                onReleased: btn_update.is_pressed = false;
            }
        }
    }
}
