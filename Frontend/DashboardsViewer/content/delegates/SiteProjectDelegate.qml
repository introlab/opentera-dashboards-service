import QtQuick 2.15
import QtQuick.Controls 2.15
import DashboardsViewer 1.0

Item {
    width: GridView.view.cellWidth - 10
    height: GridView.view.cellHeight - 10

    signal itemClicked(var id, var definition)

    Rectangle {
        color: model.color
        anchors.fill: parent

        Text {
            anchors.fill: parent
            text: model.name
            color: Constants.textColor
            font.pixelSize: Constants.smallFontSize
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            style: Text.Outline
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: function(){
                //console.log("Click! " + model.id + " - " + model.definition);
                itemClicked(model.id, model.definition);
            }
        }
    }
}
