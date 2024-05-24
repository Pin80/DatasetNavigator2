import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles  1.4
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import QtGraphicalEffects 1.12
import GlobalProp 1.0

Item {
    property alias panel_folder: dirdialog_orig.folder
    property alias panel_maskfolder: dir_mdialogM.folder
    readonly property int fldButtonPanrlHeight: 120*TStyle.scaleky
    signal updatelists();
    ColumnLayout {
        anchors.fill: parent
        spacing: 1
        anchors.margins: 2
        TButton_gradient {
            id: btn_selectdir
            btntext: qsTr("Image Folder")
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            Layout.preferredHeight: fldButtonPanrlHeight*0.35
            TFileDialog {
                id: dirdialog_orig
                onAccepted: {
                    console.log("folder")
                }
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    console.log("folder dialog called")
                    dirdialog_orig.title = "Please choose a image folder"
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
            btntext: qsTr("Mask Image Folder")
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            Layout.preferredHeight: fldButtonPanrlHeight*0.35
            TFileDialog {
                id: dir_mdialogM
                onAccepted: {
                    dir_mdialogM.close()
                }
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    dir_mdialogM.title = "Please choose a mask folder"
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
            btntext: qsTr("Update lists")
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
