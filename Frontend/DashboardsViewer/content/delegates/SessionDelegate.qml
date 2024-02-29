import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts

Item {
    id: myDelegate

        Rectangle {
            id: myRectangle
            width: parent.width
            height: 80
            color: "#cccccc"
            border.color: "black"
            border.width: 1
            radius: 5

            ColumnLayout {
                id: columnLayout
                anchors.fill: parent

                Text {
                    id: text1
                    text: id_session + "(" + session_name + ")"
                    font.bold: true
                    font.pixelSize: 20
                    color: "black"
                }

            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: {
                    console.log("SessionDelegate clicked");
                }
            }
        }
    } // Component
