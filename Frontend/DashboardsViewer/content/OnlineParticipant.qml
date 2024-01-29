import QtQuick 2.15

OnlineParticipantForm {
    id: currentOnlineParticipant
    function update(participantObject) {

        /*
        qml: OnlineParticipants  0  [id_participant] : 1
        qml: OnlineParticipants  0  [id_participant_group] : null
        qml: OnlineParticipants  0  [id_project] : 1
        qml: OnlineParticipants  0  [participant_busy] : false
        qml: OnlineParticipants  0  [participant_email] :
        qml: OnlineParticipants  0  [participant_enabled] : true
        qml: OnlineParticipants  0  [participant_name] : TestUser
        qml: OnlineParticipants  0  [participant_online] : true
        qml: OnlineParticipants  0  [participant_token_enabled] : true
        qml: OnlineParticipants  0  [participant_uuid] : dd75a936-7cc0-4ca5-af30-32fbe28bc760
        */

        id_participant = participantObject["id_participant"];
        id_participant_group = participantObject["id_participant_group"];
        participant_name = participantObject["participant_name"];
    }




    /*
    Timer {
        id: timeToLiveTimer
        interval: 10000
        running: true
        repeat: false

        onTriggered: function() {
            //Destroy object
            console.log("TTL", currentOnlineParticipant);
            currentOnlineParticipant.destroy();
        }
    }
    */

}
