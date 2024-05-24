import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel 2.0


FileDialog {
    title: "Please choose a file";
    //nameFilters: ["Image Files (*.jpg *.png *.gif)"];
    selectFolder: true
    selectMultiple: false
    visible: false
}
