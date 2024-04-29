import QtQuick 2.15
import QtQuick.Controls 2.15

import OpenTeraLibs.UserClient 1.0
import DashboardsViewer.ConfigParser 1.0

import DashboardsViewer
import ".."

Item {
    //width: 1024
    //height: 768
    //anchors.fill: parent
    property string definition: ""

    signal buttonClicked

    ConfigParser {
        id: parser
    }

    function loadDocument(filename = undefined) {
        console.log("should load document", definition)

        var dynamicQML;
        if (filename){
            dynamicQML = parser.parseConfigFile(filename);
        }else{
            dynamicQML = parser.parseConfigString(definition);
        }


        console.log("dynamicQML", dynamicQML)

        if (dynamicQML.length > 0) {
            for (var i = 0; i < dynamicQML.length; i++) {

                try {
                    //Create object from dynamicQML
                    var dynamicObject = Qt.createQmlObject(dynamicQML[i],
                                                           dashboardStackView)

                    console.log("dynamicObject", dynamicObject)

                    // Push to stackView
                    if (dynamicObject) {
                        dashboardStackView.push(dynamicObject)
                    }
                } catch (e) {
                    console.log("Error", e)
                }
            }
        }
    }

    LoadingScreen{
        id: screenLoading
        visible: false
        z: 3
    }

    StackView {
        id: dashboardStackView
        anchors.fill: parent
    }
}
