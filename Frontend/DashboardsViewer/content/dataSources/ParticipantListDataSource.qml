import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import OpenTeraLibs.UserClient 1.0
import "../delegates"

Item {

    property string url: "" // Empty URL
    property int id_project: 0 // Empty Project
    property ListModel model: ListModel {
        id: myModel
    }

    id: fetch
    signal dataReady(var data);
    signal error(string message);
    signal participantClicked(int id_participant);

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
                filteredItem.id_participant = item.id_participant;
                filteredItem.participant_uuid = item.participant_uuid;
                filteredItem.participant_enabled = item.participant_enabled;
                filteredItem.id_project = item.id_project;

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


