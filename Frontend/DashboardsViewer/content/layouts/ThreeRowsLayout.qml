import QtQuick 2.15
//import OpenTeraLibs.UserClient 1.0
//import DashboardsViewer
import QtQuick.Layouts

/**
    Dashboard basic layout with 3 rows
*/
Item {
    anchors.fill: parent
    id: mainLayout
    property alias row1: row1
    property alias row2: row2
    property alias row3: row3

    ColumnLayout {
        id: columnLayout
        anchors.fill: parent
        spacing: 10

        // Row 1
        RowLayout {
            id: row1
            width: columnLayout.width
            height: columnLayout.height / 3
        }

        // Row 2
        RowLayout {
            id: row2
            width: columnLayout.width
            height: columnLayout.height / 3
        }

        // Row 3
        RowLayout {
            id: row3
            width: columnLayout.width
            height: columnLayout.height / 3
        }
    }

}
