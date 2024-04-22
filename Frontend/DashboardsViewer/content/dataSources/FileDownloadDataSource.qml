import QtQuick 2.15
import OpenTeraLibs.UserClient 1.0

Item {
    id: fileDownloadDataSource
    property string url: "" // Empty URL
    property var params: Object()
    property bool autoFetch: false
    property string filename: ""

    signal downloadProgress(var bytesReceived, var bytesTotal);
    signal downloadStarted();
    signal downloadFinished();
    signal downloadFailed();


    function downloadFile() {

        if (filename)
        {
            console.log("Should download file and save to: ", filename );
            var fileDownloader = UserClient.downloadFile(filename, url, params);

            fileDownloader.finished.connect(function() {
                console.log("Finished");
                downloadFinished();
            });

            fileDownloader.downloadProgress.connect(function(bytesReceived, bytesTotal) {
                console.log("DownloadProgress ", bytesReceived, bytesTotal);
                downloadProgress(bytesReceived, bytesTotal);
            });
        }
        else {
            downloadFailed();
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

}
