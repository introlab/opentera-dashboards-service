import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15

Item {
    id: myDelegate
    width: parent.width
    height: 80

    Rectangle {
        id: myRectangle
        width: parent.width
        height: parent.height
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
                height: parent.height
                width: parent.width
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
