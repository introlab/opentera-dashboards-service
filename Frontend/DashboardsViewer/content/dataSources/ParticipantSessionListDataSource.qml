import QtQuick 2.15
import OpenTeraLibs.UserClient 1.0


BaseDataSource {
    id: fetch
    property int id_participant: 0 // Empty Project

    params: {"id_participant": id_participant}
    url: "/api/user/sessions"
    fieldIdName: "id_session"
    fieldDisplayName: "session_name"
    iconPath: "qrc:/genericIcon"

    function setParticipant(id_participant) {
        fetch.id_participant = id_participant;
        getAll();
    }

}
