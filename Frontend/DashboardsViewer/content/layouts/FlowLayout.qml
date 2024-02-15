import QtQuick 2.15
//import OpenTeraLibs.UserClient 1.0
//import DashboardsViewer
import QtQuick.Layouts

/**
    Dashboard basic layout with Flow
*/
Item {
    anchors.fill: parent
    id: mainLayout
    property alias flow: flow

    Flow {
        id: flow
        anchors.fill: parent
        spacing: 3
    }
}
