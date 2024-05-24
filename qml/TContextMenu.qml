import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles  1.4
import GlobalProp 1.0

Menu {
    id: menu
    MenuSeparator {
        contentItem: Rectangle {
            implicitWidth: menu.width
            implicitHeight: 1
            color: TStyle.background_small
        }
    }
    topPadding: 2
    bottomPadding: 2
    delegate: MenuItem {
        id: menuItem
        implicitWidth: parent.width
        implicitHeight: 30*TStyle.scaleky
        contentItem: Text {
            leftPadding: 10*TStyle.scalekx
            rightPadding: 10*TStyle.scalekx
            width: parent.width
            height: parent.height
            font.pointSize: 14*TStyle.scaleky
            minimumPointSize: 14*TStyle.scaleky
            text: menuItem.text
            //font: menuItem.font
            opacity: enabled ? 1.0 : 0.3
            color: TStyle.list_text
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            fontSizeMode: Text.Fit
        }

        background: Rectangle {
            width: parent.width
            height: parent.height
            opacity: enabled ? 1 : 0.3
            color: menuItem.highlighted ? TStyle.list_select : "transparent"
        }
    }

    background: Rectangle {
        implicitWidth: 200*TStyle.scalekx
        color: TStyle.list_even
        border.color: TStyle.background_border
        radius: 2
    }
}
