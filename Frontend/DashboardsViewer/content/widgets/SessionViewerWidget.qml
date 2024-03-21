import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import DashboardsViewer 1.0
import QtQuick.Dialogs
import QtCore
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
                        id: assetItemDelegate
                        width: assetsList.width                        
                        height: 40

                        function delegateModel() {
                            return model
                        }

                        BasicButton {
                            id: singleAssetDownloadButton
                            anchors.fill: parent
                            text: delegateModel().asset_name + " [" + delegateModel().asset_uuid + "]"
                            onClicked: {
                                console.log("Download button clicked for asset: " + delegateModel().asset_name + " [" + delegateModel().asset_uuid + "]");
                                saveFileDialog.open();
                            }
                        }
                        Text {
                            id: singleAssetInfoText
                            anchors.right: singleAssetDownloadButton.right
                            anchors.top: singleAssetDownloadButton.top
                            anchors.bottom: singleAssetDownloadButton.bottom
                            text: "Hello World!"
                        }

                        FileDownloadDataSource {
                            id: fileDownloadDataSource
                            url: "/file/api/assets"
                            filename: delegateModel().asset_name
                            params: {"asset_uuid": delegateModel().asset_uuid, "access_token": delegateModel().access_token}
                        }

                        BaseDataSource {
                            id: assetInfoDataSource
                            url: "/file/api/assets/infos"
                            params: {"asset_uuid": delegateModel().asset_uuid, "access_token": delegateModel().access_token}
                            autoFetch: true

                            //Be careful, we are using model from BseDataSource not the delegate item
                            model.onCountChanged: function() {
                                console.log("infos count changed");
                                var assetInfo = model.get(0);
                                singleAssetInfoText.text = "Size: " + (assetInfo.asset_file_size / (1024.0 * 1024.0)).toString() + " MB"
                            }
                        }

                        //Download progress dialog
                        Dialog {
                            id: downloadProgressDialog
                            title: "Downloading " + delegateModel().asset_name
                            standardButtons: Dialog.Close
                            anchors.centerIn: assetItemDelegate
                            width: assetsList.width / 2
                            height: assetsList.height / 2
                            enabled: false

                            ProgressBar {
                                id: progressBar
                                from: 0
                                to: 100
                                value: 0
                                anchors.fill: parent
                            }

                            Connections
                            {
                                target: fileDownloadDataSource
                                onDownloadProgress: function(bytesReceived, bytesTotal){
                                    console.log("DownloadProgressDialog progress: ", bytesReceived, bytesTotal);
                                    progressBar.value = bytesReceived / bytesTotal * 100;
                                }
                                onDownloadFinished: function() {
                                    console.log("DownloadProgressDialog finished");
                                    downloadProgressDialog.enabled = true;
                                }
                            }

                            onAccepted: {
                                console.log("DownloadProgressDialog accepted");
                                saveFileDialog.open();
                            }
                        }

                        FileDialog {
                            id: saveFileDialog
                            nameFilters: ["All files (*)"]
                            fileMode: FileDialog.SaveFile
                            //URL
                            currentFolder: StandardPaths.writableLocation(StandardPaths.DownloadLocation)
                            currentFile: delegateModel().asset_name
                            onAccepted: function() {
                                console.log("SaveFileDialog accepted");
                                fileDownloadDataSource.filename = saveFileDialog.currentFile;
                                downloadProgressDialog.open();
                                fileDownloadDataSource.downloadFile();
                            }
                         }
                    } // Item (delegate)

                    BaseDataSource {
                        id: assetsDataSource
                        url: "/api/user/assets"                        
                        params: {"id_session": session.id_session, "with_urls": true, "full": true}
                        autoFetch: true
                    }


                }//ListView



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
