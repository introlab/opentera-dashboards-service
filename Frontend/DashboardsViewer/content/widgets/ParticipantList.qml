import QtQuick 2.15
import OpenTeraLibs.UserClient 1.0
import DashboardsViewer

Rectangle {
    width: 640
    height: 480
    color: "lightgray"

    property int project_id: 1
    property int site_id: 1
    property string url: "/api/user/participants"


    MouseArea {
        anchors.fill: parent
        onClicked: {
            var params = {
                "id_project": project_id,
            }
            var reply = UserClient.get(url, params);

            reply.requestSucceeded.connect(function(response, statusCode) {
                console.log("Success", response, statusCode);
            });

            reply.requestFailed.connect(function(response, statusCode) {
                console.log("Failed", response, statusCode);
            });

        }
    }

    Connections {
        target: UserClient

    }
}

