import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Effects

import "../ui"
import DashboardsViewer 1.0

Item {
    //property alias btnOK: btnStart
    //property alias fileName: inputJSON.text
    property alias cmbSites: cmbSites
    property alias cmbProjects: cmbProjects
    property alias siteGridView: siteGridView
    property alias projetGridView: projectGridView

    Item {
        anchors.centerIn: parent
        width: 0.8 * parent.width
        height: 0.9 * parent.height

        BasicDialog {
            id: dlgMain
            title: qsTr("Select dashboard to display")
            anchors.fill: parent

            Flickable {
                id: flickMain
                anchors.fill: parent
                anchors.topMargin: 10
                anchors.bottomMargin: 10
                clip: true
                contentHeight: layoutMain.implicitHeight
                interactive: height < contentHeight

                ScrollBar.vertical: FlickableScrollBar {}

                ColumnLayout {
                    id: layoutMain
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: flickMain.interactive ? 15 : 10

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: rowFilters.implicitHeight + lblFilters.implicitHeight
                                        + rowFilters.anchors.margins * 2

                        radius: 10
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
                        }//RowLayout
                    } // First Rect

                    Rectangle {
                        id: siteProjectGrids
                        color: "White"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 10
                        implicitHeight: 200


                        RowLayout {
                            //Fill the rest
                            //Where dashboards should be presented
                            id: siteProjectRowLayout
                            anchors.fill: parent

                            GridView {
                                id: siteGridView
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                cellWidth: 100
                                cellHeight: 100
                                model: ListModel {}
                                delegate: Rectangle {
                                    color: Green
                                    width: siteGridView.cellWidth
                                    height: siteGridView.cellHeight

                                    Text {
                                        anchors.fill: parent
                                        text: model.name
                                        color: Constants.textColor
                                        font.pixelSize: Constants.smallFontSize
                                        style: Text.Outline
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent

                                    }
                                }
                            } // GridView 1

                            GridView {
                                id: projectGridView
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                model: ListModel {}
                                cellWidth: 100
                                cellHeight: 100
                                delegate: Rectangle {
                                    color: "Red"
                                    width: projectGridView.cellWidth
                                    height: projectGridView.cellHeight

                                    Text {
                                        anchors.fill: parent
                                        text: model.name
                                        color: Constants.textColor
                                        font.pixelSize: Constants.smallFontSize
                                        style: Text.Outline
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent

                                    }
                                }
                            } // GridView 2

                        }//RowLayout (2)
                    } // Rectangle 2
                } // ColumnLayout
            } // Flickable
        } // BasicDialog
    } // Item
} // Item
