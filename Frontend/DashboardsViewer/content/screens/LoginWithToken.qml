import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Effects

import OpenTeraLibs.UserClient

import DashboardsViewer
import "../ui"

Item {


    Component.onCompleted: {
        //Doing something
        console.log("connecting to ", AppURL);
        timerLoading.start();
    }

    Timer{
        id: timerLoading
        running: false
        interval: 0
        onTriggered: function() {
            UserClient.connectWithTokenUrl(AppURL);
        }
    }

    Connections {
        target: UserClient
        onLoginSucceeded: function() {
            console.log("onLoginSucceeded");

            //Query user information
            var reply = UserClient.get("/api/user/users", {"self": true});

            reply.requestSucceeded.connect(function(response, statusCode) {
                //console.log("Success", response, statusCode);
                var userInfo = response[0];
                menu.displayUsername = userInfo.user_firstname + " " + userInfo.user_lastname;
            });

            menu.visible = true;
            stackview.push("DashboardSelector.qml");
        }
        onLoginFailed: function(error) {
            console.log("onLoginFailed");

        }
    }
}


