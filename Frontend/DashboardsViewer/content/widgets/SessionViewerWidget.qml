import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import DashboardsViewer 1.0
import QtQuick.Dialogs
import QtCore
import "../ui"
import "../dataSources"

Item {
    id: rootItem
    property var session: null

    BasicDialog {
        id:mySessionViewerWidget

        showCloseButton: true
        stackView:  dashboardStackView ? dashboardStackView : null

        width: 0.9 * parent.width
        height: 0.9 * parent.height
        anchors.centerIn: parent

        Rectangle {
            id: background
            anchors.fill: parent
            color: Constants.backgroundColor

            ColumnLayout {
                id: sessionLayout
                spacing: 10
                anchors.fill: parent
                anchors.margins: 10
                RowLayout{
                    Layout.fillWidth: true
                    Badge{
                        visible: session.session_type_name
                        text: session.session_type_name
                        color: session.session_type_color ? session.session_type_color : "white"
                        font.pixelSize: Constants.baseFontSize
                        padding: 0
                        textColor: "black"
                    }
                    Badge{
                        visible: session.session_status === 2
                        text: qsTr("Completed")
                        color: "darkgreen"
                        font.pixelSize: Constants.baseFontSize
                        padding: 0
                    }
                    Badge{
                        visible: session.session_status === 3
                        text: qsTr("Cancelled")
                        color: "darkred"
                        font.pixelSize: Constants.baseFontSize
                        padding: 0
                    }
                    Badge{
                        visible: session.session_status === 4
                        text: qsTr("Terminated")
                        color: "red"
                        font.pixelSize: Constants.baseFontSize
                        padding: 0
                    }
                    Badge{
                        visible: session.session_status === 1
                        text: qsTr("In progress")
                        color: "darkgrey"
                        font.pixelSize: Constants.baseFontSize
                        padding: 0
                    }
                    Badge{
                        visible: session.session_status === 0
                        text: qsTr("Planned")
                        color: "white"
                        font.pixelSize: Constants.baseFontSize
                        padding: 0
                        textColor: "black"
                    }
                }

                /*Rectangle {
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
                }*/
                Rectangle{
                    Layout.fillWidth: true
                    implicitHeight: layoutHeader.implicitHeight + layoutHeader.anchors.margins*2
                    color: Constants.lightBackgroundColor
                    radius: 10
                    ColumnLayout{
                        id: layoutHeader
                        anchors.fill: parent
                        anchors.margins: 10
                        Text{
                            id: txtDate
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            property date sessionDate: new Date(session.session_start_datetime)
                            text: sessionDate.toLocaleDateString() +" - " + sessionDate.toLocaleTimeString()
                            font.pixelSize: Constants.baseFontSize
                            style: Text.Outline
                            font.bold: true
                            color: Constants.textAltColor
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                        Text{
                            id: txtName
                            Layout.fillWidth: true
                            text: session.session_name
                            font.pixelSize: Constants.baseFontSize * 1.2
                            wrapMode: Text.WordWrap
                            style: Text.Outline
                            color: Constants.textColor
                        }
                    }
                }


                Rectangle {
                    id: sessionComments
                    Layout.fillWidth: true
                    implicitHeight: layoutComments.implicitHeight
                    color: Constants.highlightColor
                    radius: 5
                    visible: session.session_comments
                    ColumnLayout{
                        id: layoutComments
                        anchors.fill: parent
                        Text {
                            id: sessionCommentsText
                            text: session.session_comments
                            color: "white"
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                    }


                }

                // Participants
                /*Rectangle {
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
                }*/

                // Assets
                Rectangle {
                    id: recAssets
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "lightgrey"
                    radius: 5
                    ColumnLayout{
                        id: assetsLayout
                        anchors.fill: parent
                        anchors.margins: 5
                        Text {
                            id: assetsText
                            Layout.alignment: Qt.alignLeft | Qt.AlignTop
                            text: qsTr("Assets")
                            font.bold: true
                            font.pointSize: Constants.baseFontSize
                        }

                        Text{
                            id: txtNoAssets
                            visible: !lstAssets.visible
                            text: qsTr("No assets")
                            verticalAlignment: Text.AlignTop
                            color: "darkred"
                            font.bold: true
                            font.pointSize: Constants.baseFontSize
                            Layout.alignment: Qt.alignLeft | Qt.AlignVCenter
                            Layout.fillHeight: true
                        }

                        ListView {
                            id: lstAssets
                            model: assetsDataSource.model
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.leftMargin: 10
                            Layout.rightMargin: 10
                            clip: true
                            visible: count > 0

                            interactive: contentHeight < height
                            spacing: 2

                            delegate: Item {
                                id: assetItemDelegate
                                width: lstAssets.width
                                height: 40

                                function delegateModel() {
                                    return model
                                }

                                BasicButton {
                                    id: singleAssetDownloadButton
                                    anchors.fill: parent
                                    text: delegateModel().asset_name + " [" + delegateModel().asset_uuid + "]"
                                    onClicked: {
                                        //console.log("Download button clicked for asset: " + delegateModel().asset_name + " [" + delegateModel().asset_uuid + "]");

                                        if (dashboardViewerApp.isWebAssembly()) {
                                            //console.log("WebAssembly is supported...")
                                            //This will use the browser download function. Download UI is provided by browser.
                                            fileDownloadDataSource.filename = delegateModel().asset_name

                                            //DownloadFile returnes a null object in WebASM
                                            fileDownloadDataSource.downloadFile();
                                        } else {
                                            //console.log('WebAssembly is not supported');
                                            saveFileDialog.open();
                                        }

                                    }
                                }
                                Text {
                                    id: singleAssetInfoText
                                    anchors.right: singleAssetDownloadButton.right
                                    anchors.top: singleAssetDownloadButton.top
                                    anchors.bottom: singleAssetDownloadButton.bottom
                                    //text: "Hello World!"
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

                                    //Be careful, we are using model from BaseDataSource not the delegate item
                                    model.onCountChanged: function() {
                                        //console.log("infos count changed");
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
                                    width: lstAssets.width / 2
                                    height: lstAssets.height / 2
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

    }
}
