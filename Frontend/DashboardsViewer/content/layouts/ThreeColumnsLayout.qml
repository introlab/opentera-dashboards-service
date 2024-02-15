import QtQuick 2.15
//import OpenTeraLibs.UserClient 1.0
//import DashboardsViewer
import QtQuick.Layouts
/**
    Dashboard basic layout with 3 colums
*/
Rectangle {
    anchors.fill: parent
    id: mainLayout
    property alias column1: column1
    property alias column2: column2
    property alias column3: column3

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        spacing: 5

        //The first column 1/3
        ColumnLayout {
            id: column1
            anchors.verticalCenter: mainLayout.verticalCenter
            width: mainLayout.width / 3
            height: mainLayout.height
        }

        //The second column 1/3
        ColumnLayout {
            id: column2
            anchors.verticalCenter: mainLayout.verticalCenter
            width: mainLayout.width / 3
            height: mainLayout.height
        }

        //The third column 1/3
        ColumnLayout {
            id: column3
            anchors.verticalCenter: mainLayout.verticalCenter
            width: mainLayout.width / 3
            height: mainLayout.height
        }
    }
}
