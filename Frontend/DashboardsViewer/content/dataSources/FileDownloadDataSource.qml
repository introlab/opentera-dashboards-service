import QtQuick 2.15
import OpenTeraLibs.UserClient 1.0

Item {
    id: fileDownloadDataSource
    property string url: "" // Empty URL
    property var params: Object()
    property bool autoFetch: false
    property string filename: ""

    function downloadFile() {
        var reply = UserClient.download(url, params);

        reply.requestSucceeded.connect(function(response, statusCode) {
            console.log("Success", response, statusCode);
         });

        reply.readyRead.connect(function() {
            console.log("ReadyRead ", reply.bytesAvailable());
        });

        reply.downloadProgress.connect(function(bytesReceived, bytesTotal) {
            console.log("DownloadProgress ", bytesReceived, bytesTotal);
        });
    }
}
