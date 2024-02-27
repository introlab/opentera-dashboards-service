import QtQuick 2.15
import QtQuick.Controls 2.15

import OpenTeraLibs.UserClient 1.0

Item {

    property string url: "" // Empty URL
    property int id_project: 0 // Empty Project
    property Component delegate:  Component {
        id: myDelegate

        // Customize delegate appearance as needed
        Text {
            width: 300
            height: 40
            text:  participant_name
        }
    }

    property ListModel model: ListModel {
        id: myModel
    }

    id: fetch
    signal dataReady(var data);
    signal error(string message);

    function getAll() {
        var params = {"id_project": id_project};
        var reply = UserClient.get(url, params);

        reply.requestSucceeded.connect(function(response, statusCode) {
            console.log("Success", response, statusCode);

            //Make sure model is empty
            myModel.clear();

            //Add participants to model
            //TODO filter fields
            response.forEach(function(item) {

                var filteredItem = {};

                //Filter fields
                filteredItem.participant_name = item.participant_name;

                myModel.append(filteredItem);
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
        getAll();
    }

}


