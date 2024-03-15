import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Effects

import "../ui"
import "../delegates"
import DashboardsViewer 1.0

Item {
    //property alias btnOK: btnStart
    //property alias fileName: inputJSON.text
    property alias cmbSites: cmbSites
    property alias cmbProjects: cmbProjects
    property alias siteGridView: siteGridView
    property alias projectGridView: projectGridView

    Item {
        anchors.centerIn: parent
        width: 0.8 * parent.width
        height: 0.9 * parent.height

        BasicDialog {
            id: dlgMain
            title: qsTr("Select dashboard to display")
            anchors.fill: parent
            ColumnLayout {
                id: layoutMain
                anchors.fill: parent
                anchors.margins: 10

                Rectangle {
                    Layout.fillWidth: true

                    implicitHeight: rowFilters.implicitHeight + lblFilters.implicitHeight
                                    + rowFilters.anchors.margins * 2

                    radius: 10
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    //color: "#77000000"
                    color: "Red"
                    Text {
                        id: lblFilters
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: 10
                        text: qsTr("Filters")
                        color: "lightyellow"
                        font.pixelSize: Constants.smallFontSize
                        font.italic: true
                    }

                    RowLayout {
                        id: rowFilters
                        anchors.top: lblFilters.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 5
                        implicitHeight: 200

                        Text {
                            text: qsTr("Site")
                            Layout.leftMargin: 20
                            color: Constants.textColor
                            font.pixelSize: Constants.smallFontSize
                            font.bold: true
                            style: Text.Outline
                        }

                        ComboBox {
                            id: cmbSites
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: ListModel {}
                        }
                        Text {
                            text: qsTr("Project")
                            color: Constants.textColor
                            font.pixelSize: Constants.smallFontSize
                            style: Text.Outline
                            font.bold: true
                        }

                        ComboBox {
                            id: cmbProjects
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: ListModel {}
                        }
                    } //RowLayout
                } // First Rect
                Rectangle {
                    id: siteProjectGrids
                    color: "white"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 10
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    //implicitHeight: 600

                    //implicitHeight: siteProjectRowLayout.implicitHeight
                    RowLayout {
                        //Fill the rest
                        //Where dashboards should be presented
                        id: siteProjectRowLayout
                        anchors.fill: parent

                        //implicitHeight: siteGridView.implicitHeight
                        GridView {
                            id: siteGridView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            cellWidth: 100
                            cellHeight: 100
                            clip: true
                            ScrollBar.vertical: FlickableScrollBar {}
                            model: ListModel {}
                            delegate: SiteProjectDelegate {}
                        } // GridView 1

                        GridView {
                            id: projectGridView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: ListModel {}
                            cellWidth: 100
                            cellHeight: 100
                            clip: true

                            ScrollBar.vertical: FlickableScrollBar {}
                            delegate: SiteProjectDelegate {}
                        } // GridView 2
                    } //RowLayout (2)
                } // Rectangle 2
            } // ColumnLayout
        } // BasicDialog
    } // Item
} // Item
