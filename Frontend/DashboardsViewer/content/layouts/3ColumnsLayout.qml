import QtQuick 2.15
//import OpenTeraLibs.UserClient 1.0
//import DashboardsViewer
import QtQuick.Layouts
/**
    Dashboard basic layout with 3 colums
*/
Item {
    anchors.fill: parent
    id: mainLayout

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        spacing: 0

        //The first column 1/3
        ColumnLayout {
            id: column1
            width: rowLayout.width / 3
            height: rowLayout.height
        }

        //The second column 1/3
        ColumnLayout {
            id: column2
            width: rowLayout.width / 3
            height: rowLayout.height
        }

        //The third column 1/3
        ColumnLayout {
            id: column3
            width: rowLayout.width / 3
            height: rowLayout.height
        }
    }
}
