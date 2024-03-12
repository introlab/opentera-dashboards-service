import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import DashboardsViewer 1.0

BaseWidget {
    id:mySessionViewerWidget
    property var session: null

    Rectangle {
        id: background
        anchors.fill: parent
        color: Constants.backgroundColor

        ColumnLayout {
            id: sessionLayout
            spacing: 10
            anchors.fill: parent
            anchors.margins: 10
            Button {
                id: button
                Layout.fillWidth: false
                Layout.fillHeight: false
                Layout.alignment: Qt.AlignRight
                implicitWidth: 200
                implicitHeight: 50
                text: "Click me to close."
                onClicked: {
                    console.log("Button clicked")
                    if (stackView.currentItem === mySessionViewerWidget) {
                        stackView.pop();
                    }
                }
            }

            Rectangle {
                id: sessionName
                Layout.fillWidth: true
                Layout.fillHeight: false
                implicitHeight: 30
                color: "lightblue"
                Text {
                    id: sessionNameText
                    text: session.session_name
                    font.bold: true
                    font.pointSize: 20
                    anchors.centerIn: parent
                }
            }
            Rectangle {
                id: sessionComments
                Layout.fillWidth: true
                Layout.fillHeight: false
                implicitHeight: 30
                color: "lightyellow"
                Text {
                    id: sessionCommentsText
                    text: session.session_comments
                    font.pointSize: 16
                    anchors.fill: parent
                    wrapMode: Text.Wrap
                }
            }
        }

    }


    Component.onCompleted: {
        console.log("Item completed")
    }
}
