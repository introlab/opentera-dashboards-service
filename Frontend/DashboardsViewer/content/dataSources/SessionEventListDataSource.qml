import QtQuick 2.15
import OpenTeraLibs.UserClient 1.0


BaseDataSource {
    id: fetch
    property int id_session: 0

    params: {"id_session": id_session}
    url: "/api/user/sessions/events"
    fieldIdName: "id_session_event"
    fieldDisplayName: "session_event_text"
    iconPath: "qrc:/genericIcon"

    function setSession(id_session) {
        fetch.id_session = id_session;
        params = {"id_session": id_session};
        getAll();
    }
}
