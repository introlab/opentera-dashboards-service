import QtQuick 2.15
import OpenTeraLibs.UserClient 1.0

Item {
    id: fileDownloadDataSource
    property string url: "" // Empty URL
    property var params: Object()
    property bool autoFetch: false
    property string filename: ""
    property string archiveUuid: ""
    property bool downloading: false

    signal downloadProgress(var bytesReceived, var bytesTotal);
    signal downloadStarted();
    signal downloadFinished();
    signal downloadFailed();


    function downloadFile() {

        if (downloading){
            console.log("Already downloading file... Ignoring another download.")
            return;
        }

        if (filename)
        {
            downloading = true;
            console.log("Should download file " + url + " and save to: ", filename );
            var fileDownloader = UserClient.downloadFile(filename, url, params);

            fileDownloader.finished.connect(function() {
                console.log("Finished");
                downloadFinished();
                downloading = false;
            });

            fileDownloader.downloadProgress.connect(function(bytesReceived, bytesTotal) {
                console.log("DownloadProgress ", bytesReceived, bytesTotal);
                downloadProgress(bytesReceived, bytesTotal);
            });
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
            params = {"id_participant": id_participant}
            var reply = UserClient.get("/api/user/assets/archive", params)

            reply.requestSucceeded.connect(function(response, statusCode) {
                console.log(response, statusCode);
            });
        }
    }

    Connections {
        target: UserClient
        onArchiveEvent: function(event) {
            console.log("ArchiveEvent: ", event)
            if (event.status === 2){
                // Completed - start download!
                let url_parts = event.archiveUrl.split("?")
                url = url_parts[0];
                params = {"archive_uuid": event.archiveUuid};
                downloadFile();
            }
        }
    }

}
