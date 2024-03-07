import QtQuick 2.15
import OpenTeraLibs.UserClient 1.0

Item {
    id: baseDataSource
    property string url: "" // Empty URL
    property ListModel model: ListModel {
        id: myModel
    }
    property var params: Object()
    property string fieldIdName: "id_"
    property string fieldDisplayName: "disp_"
    property string iconPath: "qrc:/genericIcon"
    property bool autoFetch: false

    signal error(var errorMessage);

    function getAll() {
        var reply = UserClient.get(url, params);

        reply.requestSucceeded.connect(function(response, statusCode) {
            console.log("Success", response, statusCode);

            //Make sure model is empty
            myModel.clear();

            //Add session
            response.forEach(function(item) {
               myModel.append(item)
            });
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
        if (baseDataSource.autoFetch)
        {
            getAll();
        }
    }
}
