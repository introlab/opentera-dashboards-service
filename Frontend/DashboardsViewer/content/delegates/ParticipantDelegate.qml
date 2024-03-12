import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15

BaseDelegate {
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


            // Customize delegate appearance as needed
            Text {
                height: 20
                Layout.fillWidth: true
                text:  "Name: " + participant_name
                color: "red"
            }

            Text {
                height: 20
                Layout.fillWidth: true
                text:  "Enabled: " + participant_enabled
                color: "green"
            }

            Text {
                height: 20
                Layout.fillWidth: true
                text:  "UUID: " + participant_uuid
                color: "blue"
            }

        }
        Component.onCompleted: function() {
            // Look for last_session
            if (model.participant_lastsession) {
                var lastSession = new Date(model.participant_lastsession)
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


        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                console.log("GenericItemDelegate clicked.")
                model.dataSource.itemSelected(model[model.dataSource.fieldIdName])
            }
        }
    }
}
