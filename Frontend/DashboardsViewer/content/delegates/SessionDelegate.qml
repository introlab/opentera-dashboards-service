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

            Text {
                id: text2
                text: session_start_datetime + " Duration: " + session_duration
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

    Component.onCompleted: function() {
        // Look for last_session
        if (model.session_start_datetime) {
            var lastSession = new Date(model.session_start_datetime)
            if (lastSession) {
                var now = new Date()
                var diff = now - lastSession

                // Difference less than a day ?
                if (diff < 1000 * 60 * 60 * 24) {
                    console.log("Less than a day")
                    myRectangle.color = "green"
                }
                else {
                    console.log("More than a day")
                    // Less than a week ?
                    if (diff < 1000 * 60 * 60 * 24 * 7) {
                        console.log("Less than a week")
                        myRectangle.color = "orange"
                    }
                    else {
                        console.log("More than a week")
                        myRectangle.color = "red"
                    }
                }
            }
            else {
                console.log("Invalid date")
                myRectangle.color = "red"
            }
        }
    }

} // Item
