import QtQuick 2.15

import OpenTeraLibs.UserClient 1.0
import DashboardsViewer.ConfigParser 1.0

DashboardForm {

    id: dashboard
    property string definition : ""

    signal buttonClicked()

    ConfigParser {
        id: parser
    }

    function loadDocument() {
        console.log("should load document", definition)

        var dynamicQML = parser.parseConfigString(definition);
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
