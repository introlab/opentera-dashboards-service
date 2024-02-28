import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import OpenTeraLibs.UserClient 1.0

Item {

    property string url: "/api/user/sessions" // Empty URL
    property int id_participant: 0 // Empty Participant
    property Component delegate:  Component {
    id: myDelegate

        Rectangle {
            id: myRectangle
            width: 500
            height: 80
            color: "#cccccc"
            border.color: "black"
            border.width: 1
            radius: 5

            ColumnLayout {
                id: columnLayout
                anchors.fill: parent

                Text {
                    id: text1
                    text: id_session + "(" + session_name + ")"
                    font.bold: true
                    font.pixelSize: 20
                    color: "black"
                }

            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: {

                }
            }
        }
    } // Component

    property ListModel model: ListModel {
        id: myModel
    }

    id: fetch
    signal dataReady(var data);
    signal error(string message);


    function setParticipant(id) {
        id_participant = id;
        update();
    }


    function getAll() {
        var params = {"id_participant": id_participant};
        var reply = UserClient.get(url, params);

        reply.requestSucceeded.connect(function(response, statusCode) {
            console.log("Success", response, statusCode);

            //Make sure model is empty
            myModel.clear();

            //Add session
            response.forEach(function(item) {
               myModel.append(item)
            });
        });

        reply.requestFailed.connect(function(response, statusCode) {
            error(response);
            console.log("Failed", response, statusCode);
        });

    }

    function update() {
        getAll();
    }


}
