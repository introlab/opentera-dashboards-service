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

    ColumnLayout {
        id: columnLayout
        anchors.fill: parent
        spacing: 0

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
