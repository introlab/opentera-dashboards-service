import QtQuick 2.15
//import OpenTeraLibs.UserClient 1.0
//import DashboardsViewer
import QtQuick.Layouts

/**
    Dashboard basic layout with 3 rows
*/
BaseLayout {
    anchors.fill: parent
    id: mainLayout
    property alias row1: row1
    property alias row2: row2
    property alias row3: row3

    ColumnLayout {
        id: columnLayout
        anchors.fill: parent
        spacing: -1

        // Row 1
        RowLayout {
            // Set the horizontal alignment to align items to the right
            id: row1
            Layout.alignment: Qt.AlignCenter
        }

        // Row 2
        RowLayout {
            // Set the horizontal alignment to align items to the right
            id: row2
            Layout.alignment: Qt.AlignCenter
        }

        // Row 3
        RowLayout {
            // Set the horizontal alignment to align items to the right
            id: row3
            Layout.alignment: Qt.AlignCenter
        }
    }

}
