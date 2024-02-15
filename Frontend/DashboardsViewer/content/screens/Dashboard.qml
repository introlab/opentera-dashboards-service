import QtQuick 2.15

import OpenTeraLibs.UserClient 1.0
import DashboardsViewer.ConfigParser 1.0

DashboardForm {

    id: dashboard
    property string json_file_name : "dashboard.json"

    signal buttonClicked()

    ConfigParser {
        id: parser
    }


    button.onClicked: function() {
        UserClient.disconnect();
    }

    loadButton.onClicked: function() {
        console.log("should load document", json_file_name)
        var dynamicQML = parser.parseConfig(json_file_name);
        console.log("dynamicQML", dynamicQML)

        if (dynamicQML.length > 0)
        {
           for (var i = 0; i < dynamicQML.length; i++)
           {

               try {
                   //Create object from dynamicQML
                   var dynamicObject = Qt.createQmlObject(dynamicQML[i], mainView);

                   console.log("dynamicObject", dynamicObject)
               }
               catch(e) {
                   console.log("Error", e)
               }
           }
        }

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
