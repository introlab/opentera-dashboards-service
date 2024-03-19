import QtQuick 2.15
import OpenTeraLibs.UserClient 1.0


BaseDataSource {
    id: fetch
    property int id_project: 0 // Empty Project
    property bool enabledOnly: false

    onEnabledOnlyChanged: {
        params = {"id_project": id_project, "full": true};
        if (enabledOnly){
            params["enabled"] = true;
        }
    }

    params: {"id_project": id_project, "full": true}
    url: "/api/user/participants"
    fieldIdName: "id_participant"
    fieldDisplayName: "participant_name"
    iconPath: "qrc:/genericIcon"
}


