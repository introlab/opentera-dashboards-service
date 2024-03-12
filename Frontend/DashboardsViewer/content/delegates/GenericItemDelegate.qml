import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15

BaseDelegate {
    id: myDelegate

    signal itemClicked(int id);

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
