import QtQuick 2.15
import OpenTeraLibs.UserClient 1.0
//import OpenTeraLibs.Protobuf

import DashboardsViewer

Item {
    id: fileDownloadDataSource
    property string url: "" // Empty URL
    property var params: Object()
    property bool autoFetch: false
    property string filename: ""
    property string archiveUuid: ""
    property bool downloading: false
    property bool compressing: false

    signal downloadProgress(var bytesReceived, var bytesTotal);
    signal downloadStarted();
    signal downloadFinished();
    signal downloadFailed();

    function downloadFile() {

        if (downloading){
            console.log("Already downloading file... Ignoring another download.");
            return;
        }

        if (filename)
        {
            downloading = true;
            console.log("Should download file " + url + " and save to: ", filename);
            var fileDownloader = UserClient.downloadFile(filename, url, params);

            if (!UserClient.isWebAssembly()){
                fileDownloader.finished.connect(function() {
                    //console.log("Finished");
                    downloadFinished();
                    downloading = false;
                });

                fileDownloader.downloadProgress.connect(function(bytesReceived, bytesTotal) {
                    console.log("DownloadProgress ", bytesReceived, bytesTotal);
                    downloadProgress(bytesReceived, bytesTotal);
                });
            }
        }
        else {
            downloadFailed();
            downloading = false;
        }

    }

    function downloadParticipantArchive(id_participant) {

        if (id_participant)
        {
            // Step #1, Call the Archive API
            params = {"id_participant": id_participant};
            var reply = UserClient.get("/api/user/assets/archive", params);

            compressing = true;

            reply.requestSucceeded.connect(function(response, statusCode) {
                //console.log(response, statusCode);
                archiveUuid = response.archive_uuid;
            });
        }
    }

    function downloadSessionArchive(id_session) {

        if (id_session)
        {
            // Step #1, Call the Archive API
            params = {"id_session": id_session};
            var reply = UserClient.get("/api/user/assets/archive", params);

            compressing = true;

            reply.requestSucceeded.connect(function(response, statusCode) {
                //console.log(response, statusCode);
                archiveUuid = response.archive_uuid;
            });
        }
    }

    function downloadSpecificAsset(asset_uuid){
        params = {"asset_uuid": asset_uuid, "with_urls": true};
        var reply = UserClient.get("/api/user/assets", params);
        reply.requestSucceeded.connect(function(response, statusCode) {
            // Download file
            params = {"asset_uuid": asset_uuid, "access_token": response[0].access_token};
            let my_url = new URL(response[0].asset_url)
            fileDownloadDataSource.url = my_url.pathname;
            downloadFile();
        });

    }

    Connections {
        target: UserClient
        onArchiveEvent: function(event) {
            if (compressing){
                //console.log("ArchiveEvent: ", event)
                if (event.archiveUuid === archiveUuid){
                    if (event.status === 2 /*ArchiveEvent.STATUS_COMPLETED*/){
                        // Completed - start download!
                        //console.log("Starting download...");
                        let url_parts = event.archiveUrl.split("?");
                        url = url_parts[0];
                        params = {"archive_uuid": event.archiveUuid};
                        downloadFile();
                        compressing = false;
                    }
                    else{

                    }
                }
            }
        }
    }

}
