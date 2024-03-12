import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15

Item {
    id: myDelegate
    height: parent ? 80 : 0
    width: parent ? parent.width : 0

    Rectangle {
        id: myRectangle
        anchors.fill: parent
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
                Layout.fillWidth: true
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
