pragma Singleton

import QtQuick 2.12
import QtQuick.Window 2.12

//console.log(folder)
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
QtObject {
    readonly property real scalekx: (Screen.desktopAvailableWidth/1920);
    readonly property real scaleky: (Screen.desktopAvailableHeight/1080);
    readonly property color background: "green"
    readonly property string background_tex: "qrc:///images/wood2.png"
    readonly property color background_small: "gray"
    readonly property color indicator: "brown"
    readonly property string indicator_tex: "qrc:///images/wood.png"
    readonly property string indicator_text: "black"
    readonly property string indicator_intext: "lightgrey"
    readonly property color indicator_pressed: "saddlebrown" //"#af6700"
    readonly property color indicator_hovered: "mistyrose" //"#af6700"
    readonly property color indicator_on: "green" //"#af6700"
    readonly property color background_border: "black"
    readonly property color list_odd : "lightblue"
    readonly property color list_even : "lightgreen"
    readonly property color list_select : "lightyellow"
    readonly property color list_text : "black"
    readonly property color test : "#00ff00"
    readonly property color test2 : "#ff0000"
}
