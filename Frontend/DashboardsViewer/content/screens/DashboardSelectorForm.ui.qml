import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Effects

import "../ui"
import DashboardsViewer 1.0

Item {
    property alias btnOK: btnStart
    property alias file_name: inputJSON.text

    Item {
        anchors.centerIn: parent
        width: 0.8 * parent.width
        height: 0.9 * parent.height

        BasicDialog {
            id: dlgMain
            title: qsTr("Select dashboard to display")

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
                        color: "#77000000"
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
                            anchors.bottom: parent.bottom
                            anchors.margins: 5
                            Text {
                                text: qsTr("Site")
                                Layout.leftMargin: 20
                                color: Constants.textColor
                                font.pixelSize: Constants.smallFontSize
                                font.bold: true
                                style: Text.Outline
                            }

                            ComboBox {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                model: ListModel {
                                    ListElement {
                                        text: "Banana"
                                    }
                                    ListElement {
                                        text: "Apple"
                                    }
                                    ListElement {
                                        text: "Coconut"
                                    }
                                }
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
                                model: ListModel {
                                    ListElement {
                                        text: "Banana"
                                    }
                                    ListElement {
                                        text: "Apple"
                                    }
                                    ListElement {
                                        text: "Coconut"
                                    }
                                }
                            }
                        }
                    }
                    Text {
                        text: qsTr("Projects")
                        font.pixelSize: Constants.baseFontSize
                        font.bold: true
                        style: Text.Outline
                        color: "lightyellow"
                    }
                    GridView {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        model: ListModel {
                            ListElement {
                                name: "Banana"
                            }
                            ListElement {
                                name: "Apple"
                            }
                            ListElement {
                                name: "Coconut"
                            }
                        }
                        delegate: Column {
                            Text {
                                text: name
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    Text {
                        text: qsTr("Sites")
                        font.pixelSize: Constants.baseFontSize
                        font.bold: true
                        style: Text.Outline
                        color: "lightyellow"
                    }
                    GridView {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }
                    Text {
                        text: qsTr("Globals")
                        font.pixelSize: Constants.baseFontSize
                        font.bold: true
                        style: Text.Outline
                        color: "lightyellow"
                    }
                    GridView {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }


                    /*Text {
                        text: "ID Site"
                    }

                    Rectangle {
                        id: recSite
                        border.color: "#3a1212"
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.fillWidth: true
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        Layout.topMargin: -parent.spacing
                        height: inputSite.implicitHeight + 20

                        TextInput {
                            id: inputSite
                            anchors.fill: parent
                            font.pixelSize: Constants.baseFontSize
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: "1"
                        }
                    }

                    Text {
                        text: "ID Project"
                    }

                    Rectangle {
                        id: recProject
                        border.color: "#3a1212"
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.fillWidth: true
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        Layout.topMargin: -parent.spacing
                        height: inputProject.implicitHeight + 20

                        TextInput {
                            id: inputProject
                            anchors.fill: parent
                            font.pixelSize: Constants.baseFontSize
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: "1"
                        }
                    }

                    Text {
                        text: "ID Dashboard"
                    }

                    Rectangle {
                        id: recDashBoard
                        border.color: "#3a1212"
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.fillWidth: true
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        Layout.topMargin: -parent.spacing
                        height: inputDashboard.implicitHeight + 20

                        TextInput {
                            id: inputDashboard
                            anchors.fill: parent
                            font.pixelSize: Constants.baseFontSize
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: "1"
                        }
                    }*/
                    Text {
                        text: "JSON Path"
                    }

                    Rectangle {
                        id: recJSON
                        border.color: "#3a1212"
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.fillWidth: true
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        Layout.topMargin: -parent.spacing
                        height: inputJSON.implicitHeight + 20

                        TextInput {
                            id: inputJSON
                            anchors.fill: parent
                            font.pixelSize: Constants.baseFontSize
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: ":/dashboards/json/TestDashboard.json"
                        }
                    }

                    BasicButton {
                        id: btnStart
                        text: qsTr("Go!")
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    }
                }
            }
        }
    }
}
