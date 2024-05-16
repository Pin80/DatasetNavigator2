import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Item{
    width: ind_play.width+t_play.width
    height:t_play.height
    id:row_play
    y:300
    x:20
    MouseArea{
        id:mA_play
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            ind_play.state= "play_hovered"
        }
        onPressed: {
            ind_play.state="play_pressed"
        }
        onExited: {
            ind_play.state="play_normal"
        }
        onReleased: {
           /* switch(ind_play.state){
            case "play_pressed":ind_play.state="play_hovered"
                break
            }*/
            ind_play.state="play_hovered"
        }
    }
    Rectangle{
        id:ind_play
        height: t_play.height
        width: 10
        color: "red"
        anchors.margins:  10
        states: [
            //normal state for 1st row
            State {
                name: "play_normal"
                PropertyChanges {target: ind_play ; width:10;color:"red"}
            },
            //hovered state for 1st row
            State {
                name: "play_hovered"
                PropertyChanges {target: ind_play ; width:25;color:"red"}

            },
            //pressed state for 1st row
            State {
                name: "play_pressed"
                PropertyChanges {target: ind_play ; width:30;color:"green"}
            }
        ]
        state: "play_normal" // Current State
        transitions: [
            //transition from normal state to pressed state and vice versa duration set to 100ms
            Transition {
                from: "play_normal";to: "play_pressed"
                reversible: true
                PropertyAnimation{
                    target: ind_play
                    properties: "width";duration: 100
                }
            },
            //transition from normal state to hovered state and vice versa duration set to 100ms
            Transition {
                from: "play_normal";to: "play_hovered"
                reversible: true
                PropertyAnimation{
                    target: ind_play
                    properties: "width";duration: 100
                }
            },
            //transition from pressed state to hovered state and vice versa duration set to 100ms
            Transition {
                from: "play_pressed";to: "play_hovered"
                reversible: true
                PropertyAnimation{
                    target: ind_play
                    properties: "width";duration: 100
                }
            }
        ]
    }

    Text{
        id: t_play
        height: 30
        text: "Play"
        font.family: "Open Sans"
        font.pixelSize:16
        anchors.margins: 5
        anchors.left:  ind_play.right
    }
}
