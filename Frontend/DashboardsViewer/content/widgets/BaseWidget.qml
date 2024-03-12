import QtQuick 2.15
import DashboardsViewer 1.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15

Item {
    id: widgetRoot
    implicitHeight: 400
    implicitWidth: 400
    property Item stackView: null

    Component.onCompleted: {
        console.log("Using StackView: ", stackView)
    }
}
