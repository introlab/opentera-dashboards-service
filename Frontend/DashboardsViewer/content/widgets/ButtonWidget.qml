import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Effects
import QtQuick.Layouts 1.15

BaseWidget {

    signal clicked() // This signal is emitted when the button is clicked

    property alias text: control.text



    Button {
        id: control

        implicitWidth: Math.max(
                           buttonBackground ? buttonBackground.implicitWidth : 0,
                           textItem.implicitWidth + leftPadding + rightPadding)
        implicitHeight: Math.max(
                            buttonBackground ? buttonBackground.implicitHeight : 0,
                            textItem.implicitHeight + topPadding + bottomPadding)
        leftPadding: 4
        rightPadding: 4

        text: ""

        background: buttonBackground
        Rectangle {
            id: buttonBackground
            color: "#0258b2"
            implicitWidth: 100
            implicitHeight: 40
            opacity: enabled ? 1 : 0.5
            radius: 5
            border.width: 2
            border.color: enabled ? "black" : "transparent"
            MouseArea {
                id: mouseHover
                anchors.fill: parent
                propagateComposedEvents: true
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            }
        }

        MultiEffect {
            source: buttonBackground
            anchors.fill: source
            shadowEnabled: enabled
            shadowBlur: 0.5
        }

        contentItem: textItem
        Text {
            id: textItem
            text: control.text

            opacity: enabled ? 1.0 : 0.5
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            style: enabled ? Text.Outline : Text.Normal
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
                    color: "#047eff"
                    border.color: "#88000000"
                }
            }
        ]
    }

    Connections {
        target: control
        onClicked: clicked()
    }
}


