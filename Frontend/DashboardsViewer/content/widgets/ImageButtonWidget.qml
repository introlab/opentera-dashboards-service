import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Effects
import QtQuick.Layouts 1.15

BaseWidget {

    signal clicked() // This signal is emitted when the button is clicked

    property alias text: control.text
    required property string imgPath
    property alias textControl: textItem

    implicitHeight: control.implicitHeight
    implicitWidth: control.implicitWidth + 10

    Button {
        id: control

        implicitWidth: iconItem.implicitWidth + leftPadding + rightPadding
        implicitHeight: iconItem.implicitHeight + topPadding + bottomPadding
        leftPadding: 4
        rightPadding: 4

        text: ""

        background: buttonBackground
        Rectangle {
            id: buttonBackground
            color: "transparent"
            implicitWidth: iconItem.implicitWidth
            implicitHeight: iconItem.implicitHeight
            opacity: enabled ? 1 : 0.5
            radius: 5

            MouseArea {
                id: mouseHover
                anchors.fill: parent
                propagateComposedEvents: true
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            }
        }

        contentItem: iconItem
        Item{
            id: iconItem
            implicitHeight: layoutIcon.implicitHeight
            implicitWidth: layoutIcon.implicitWidth
            RowLayout{
                id: layoutIcon
                anchors.fill: parent
                Image{
                    id: imgIcon
                    source: imgPath
                    width: 32
                    height: width
                    sourceSize.width: width
                    sourceSize.height: height
                }

                Text {
                    id: textItem
                    text: control.text
                    visible: control.text

                    opacity: enabled ? 1.0 : 0.5
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    style: enabled ? Text.Outline : Text.Normal
                }
            }
        }
    }
    states: [
        State {
            name: "down"
            when: control.down || (mouseHover.containsMouse && enabled)
            PropertyChanges {
                target: textItem
                color: "black"
                style: Text.Normal
            }

            PropertyChanges {
                target: buttonBackground
                color: "#55000033"
            }
        }
    ]

    Connections {
        target: control
        onClicked: clicked()
    }
}


