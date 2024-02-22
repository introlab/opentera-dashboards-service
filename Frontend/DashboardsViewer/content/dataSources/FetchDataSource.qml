import QtQuick 2.15
import OpenTeraLibs.UserClient 1.0
import DashboardsViewer.ConfigParser 1.0



Item {

    property string url: "" // Empty URL
    property var params: ({}) //Empty Object

    id: fetch

    signal dataReady(var data);
    signal error(string message);

    function getAll() {

        var reply = UserClient.get(url, params);

        reply.requestSucceeded.connect(function(response, statusCode) {
            console.log("Success", response, statusCode);
            dataReady(response);
            //textOutput.text = JSON.stringify(response);
        });

        reply.requestFailed.connect(function(response, statusCode) {
            error(response);
            console.log("Failed", response, statusCode);
        });

    }

    function update() {
        getAll();
    }


    Component.onCompleted: function() {
        //Get data from user client
        getAll();
    }

}


