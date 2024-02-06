import QtQuick 2.15

import OpenTeraLibs.UserClient 1.0
import DashboardsViewer.ConfigParser 1.0

DashboardForm {

    property string json_file_name : "dashboard.json"

    signal buttonClicked()

    button.onClicked: function() {
        UserClient.disconnect();
    }

    load_button.onClicked: function() {
        console.log("should load document", json_file_name)

        var parser = new ConfigParser()
        parser.parseConfig(json_file_name);
    }

    function addOnlineParticipant(participant)
    {
        console.log("addOnlineParticipant", participant);

        var component = Qt.createComponent("OnlineParticipant.qml");

        if (component.status === Component.Ready)
        {
            // Create dynamic object, can add dict wit data sources...
            var participantObject = component.createObject(flow_view);
            // Update from dict
            participantObject.update(participant)
        }

    }

    function removeOnlineParticipant(item) {
        console.log("removeOnlineParticipant", item)
    }

}
