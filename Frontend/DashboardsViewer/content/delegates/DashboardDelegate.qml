import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Effects
import QtQuick.Layouts
import DashboardsViewer 1.0

Item {
    width: GridView.view.cellWidth - 10
    height: mainLayout.implicitHeight + 10 //GridView.view.cellHeight - 10

    signal itemClicked(var id, var definition)

    states: [
        State {
            name: "hover"
            when: mouseZone.containsMouse && enabled
            PropertyChanges {
                target: recBackground
                color: "#44ffffff"
            }
        }
    ]

    MouseArea {
        id: mouseZone
        anchors.fill: parent
        propagateComposedEvents: true
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: function(){
            //console.log("Click! " + model.id + " - " + model.definition);
            itemClicked(model.id, model.definition);
        }
    }
    Rectangle{
        id: recBackground
        anchors.fill: parent
        radius: 5
        color: "transparent"
    }

    ColumnLayout{
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 5
        spacing: 5

        Item{
            height: imgDashboard.height
            Layout.fillWidth: true

            Image{
                id: imgDashboard
                anchors.centerIn: parent
                source: "../images/icons/dashboard.png"
                fillMode: Image.PreserveAspectFit
                height: 64
            }
            MultiEffect{
                source: imgDashboard
                anchors.fill: source
                shadowEnabled: true
                shadowScale: 0.90
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: model.name
            color:  model.color //Constants.textColor
            font.pixelSize: Constants.smallFontSize
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            style: Text.Outline
            font.bold: true
        }
    }
}
