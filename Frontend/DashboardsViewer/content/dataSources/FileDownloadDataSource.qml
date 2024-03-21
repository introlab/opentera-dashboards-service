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
        var reply = UserClient.download(url, params);

        reply.requestSucceeded.connect(function(response, statusCode) {
            console.log("Success", response, statusCode);
         });

        reply.requestFailed.connect(function(errorString, statusCode) {
            console.log("Failed", errorString, statusCode);
            downloadFailed();
        });

        reply.finished.connect(function() {
            console.log("Finished");
            downloadFinished();
        });

        reply.readyRead.connect(function() {
            console.log("ReadyRead ", reply.bytesAvailable());
            var data = reply.readAll();

        });

        reply.downloadProgress.connect(function(bytesReceived, bytesTotal) {
            console.log("DownloadProgress ", bytesReceived, bytesTotal);
            downloadProgress(bytesReceived, bytesTotal);
        });
    }
}
