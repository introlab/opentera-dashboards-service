import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Effects

import "../ui"
import DashboardsViewer 1.0

Item {
    property alias btnOK: btnStart

    Item {
        anchors.centerIn: parent
        implicitWidth: dlgMain.implicitWidth
        implicitHeight: dlgMain.implicitHeight
        BasicDialog {
            id: dlgMain

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 10

                Text {
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
                }

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
                        text: ":/json/dashboard/text.json"
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
