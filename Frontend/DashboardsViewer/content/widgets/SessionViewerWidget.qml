import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import DashboardsViewer 1.0
import "../ui"
import "../dataSources"

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
                    text: session.session_name + " [" + session.session_uuid + "]"
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

            // Participants
            Rectangle {
                id: participants
                Layout.fillWidth: true
                Layout.fillHeight: false
                implicitHeight: 30
                color: "lightgreen"
                Text {
                    id: participantsText
                    text: "Participants:"
                    font.bold: true
                    font.pointSize: 20
                    anchors.centerIn: parent
                }

                Component.onCompleted: function() {
                    //Fill text with participant information
                    //for (var i = 0; i < mySessionViewerWidget.session.session_participants.length; i++) {
                    //    participantsText.text += mySessionViewerWidget.session.session_participants[i] + ", ";
                    //}
                }
            }

            // Assets
            Rectangle {
                id: assets
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "lightgrey"
                Text {
                    id: assetsText
                    text: "Assets:"
                    height: 40
                    font.bold: true
                    font.pointSize: 20
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                ListView {
                    id: assetsList
                    model: assetsDataSource.model
                    anchors.top: assetsText.bottom
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    delegate: Item {
                        width: assetsList.width
                        height: 40
                        BasicButton {
                            id: singleAssetDownloadButton
                            anchors.fill: parent
                            text: model.asset_name + " [" + model.asset_uuid + "]"
                            onClicked: {
                                console.log("Download button clicked for asset: " + model.asset_name + " [" + model.asset_uuid + "]");
                                fileDownloadDataSource.downloadFile();
                            }
                        }            
                        FileDownloadDataSource {
                            id: fileDownloadDataSource
                            url: model.asset_url
                            filename: model.asset_name
                            params: {"asset_uuid": model.asset_uuid, "access_token": model.access_token}
                        }
                    }

                    BaseDataSource {
                        id: assetsDataSource
                        url: "/api/user/assets"                        
                        params: {"id_session": session.id_session, "with_urls": true, "full": true}
                        autoFetch: true
                    }
                }
            }



            // Download Assets button
            BasicButton {
                id: downloadAssetsButton
                Layout.fillWidth: false
                Layout.fillHeight: false
                Layout.alignment: Qt.AlignLeft
                implicitWidth: 200
                implicitHeight: 50
                text: "Download Assets"                
                onClicked: {
                    console.log("Download Assets button clicked")

                }
            }

        }
    }


    Component.onCompleted: {
        console.log("Item completed")
    }
}
