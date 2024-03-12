import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15

Item {
    id: myDelegate

    signal itemClicked(int id);

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


            // Customize delegate appearance as needed
            Text {
                height: 20
                width: parent.width
                text:  "Name: " + model[model.dataSource.fieldDisplayName]
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
            //console.log("GenericItemDelegate - " + myDelegate.ListView.view.fieldDisplayName);
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
