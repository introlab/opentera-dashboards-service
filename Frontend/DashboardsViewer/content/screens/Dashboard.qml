import QtQuick 2.15

import OpenTeraLibs.UserClient 1.0
import DashboardsViewer.ConfigParser 1.0

DashboardForm {

    id: dashboard
    property string jsonFileName : "dashboard.json"

    signal buttonClicked()

    ConfigParser {
        id: parser
    }


    logoutButton.onClicked: function() {
        UserClient.disconnect();
    }

    loadButton.onClicked: function() {
        console.log("should load document", jsonFileName)
        var dynamicQML = parser.parseConfig(jsonFileName);
        console.log("dynamicQML", dynamicQML)

        if (dynamicQML.length > 0)
        {
           for (var i = 0; i < dynamicQML.length; i++)
           {

               try {
                    //Create object from dynamicQML
                    var dynamicObject = Qt.createQmlObject(dynamicQML[i], dashboardStackView);

                    console.log("dynamicObject", dynamicObject)

                    // Push to stackView
                    if (dynamicObject)
                    {
                        dashboardStackView.push(dynamicObject);
                    }

               }
               catch(e) {
                   console.log("Error", e)
               }
           }
        }
    }

    closeButton.onClicked: function() {
        stackview.pop();
    }
}
