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

    Text {
        id: dashboardText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        text: qsTr("DASHBOARD")
        font.pixelSize: 60
        height: 60
        horizontalAlignment: Text.AlignHCenter
    }

    Button {
        id: closeButton
        anchors.left: parent.left
        anchors.top: parent.top
        width: 150
        height: 60
        text: qsTr("Close")
        onClicked: function () {
            stackview.pop()
        }
    }

    StackView {
        id: dashboardStackView
        anchors.top: dashboardText.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }
}
