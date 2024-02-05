import QtQuick 2.15

import OpenTeraLibs.UserClient 1.0

DashboardForm {

    signal buttonClicked()

    button.onClicked: function() {
        UserClient.disconnect();
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
