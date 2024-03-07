import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts

Item {
    property string fieldIdName: "id_"
    property string fieldDisplayName: "disp_"
    property string iconPath: "qrc:/genericIcon"

    id: myDelegate

    signal itemClicked(int id);

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
                text:  "Name: " + model[fieldDisplayName]
                color: "red"
            }
/*
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
*/
        }
        Component.onCompleted: function() {
            console.log("GenericItemDelegate");
        }


        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                itemClicked(model[fieldIdName]);
            }
        }
    }
}
