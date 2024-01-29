import QtQuick 2.15

DashboardForm {

    signal buttonClicked()

    button.onClicked: function() {
        console.log("Logout Button Pressed");
        buttonClicked();
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
