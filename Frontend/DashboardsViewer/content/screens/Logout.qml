import QtQuick
import QtQuick.Controls

import DashboardsViewer

Item {
    //anchors.fill: parent

    property alias text: txtInfos.text
    property int progressValue: -1

    Rectangle{
        id: recFiller
        anchors.fill: parent
        color: "#aa000000"
        Column{
            anchors.centerIn: parent
            spacing: 10
            Text{
                id: txtInfos
                font.pixelSize: Constants.largeFontSize
                color: "white"
                text: qsTr("Disconnected. Reload page to login again.")
            }
        }
        MouseArea{
            anchors.fill: parent
        }
    }
}
