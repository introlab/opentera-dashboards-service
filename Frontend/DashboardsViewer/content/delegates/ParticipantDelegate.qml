import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts


Component {
    id: myDelegate

    // Default property values
    property string participant_name: ""
    property string participant_enabled: ""
    property string participant_uuid: ""
    property int id_participant: 0
    property int id_project: 0

    signal participantClicked(int id);


    Rectangle {
        id: myRectangle
        width: 500
        height: 80
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
                text:  "Name: " + participant_name
                color: "red"
            }

            Text {
                height: 20
                text:  "Enabled: " + participant_enabled
                color: "green"
            }

            Text {
                height: 20
                text:  "UUID: " + participant_uuid
                color: "blue"
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                console.log("Clicked on: " + participant_name);
                console.log("Id participant", id_participant);
                console.log("Id project", id_project)
                participantClicked(id_participant);
            }
        }
    }
} // Component
