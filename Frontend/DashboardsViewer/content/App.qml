// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick 6.2
import QtQuick.VirtualKeyboard 6.2
import QtQuick.Controls 6.2

import DashboardsViewer
import "screens"

import OpenTeraLibs.UserClient 1.0

Window {
    width: Constants.width
    height: Constants.height

    visible: true
    title: "DashboardsViewer"
    id: mainWindow

    Rectangle{
        anchors.fill: parent
        gradient: Gradient {
                GradientStop { position: 0.0; color: Constants.backgroundColor }
                GradientStop { position: 0.5; color: Constants.lightBackgroundColor }
                GradientStop { position: 1.0; color: Constants.backgroundColor }
            }
    }

    StackView {
        id: stackview
        initialItem: Login {}
        anchors.fill: parent
    }

    Connections {
        target: UserClient
        onLoginSucceeded: function() {

            //After login, test wapper
            /*var params = {};
            var headers = {};
            var wrapper = UserClient.get("/api/user/participants/online", params, headers);
            console.log("found wrapper", wrapper);

            wrapper.requestSucceeded.connect(
                                function(response) {
                                    console.log("Hello world!", response)
                                });
            */



            //Show Dashboard
            stackview.push("screens/Dashboard.qml");

            /*getParticipantsTimer.running = true;
            getUsersTimer.running = true;
            getDevicesTimer.running = true;*/
        }
        onLogoutSucceeded: function() {
            console.log("logout success!");
            stackview.pop(-1)

            /*getParticipantsTimer.running = false;
            getUsersTimer.running = false;
            getDevicesTimer.running = false;*/
        }
    }

/*
    Item {
        id: dashboardView
        visible: false

        function addOnlineParticipant(participant)
        {
            console.log("dashboardView adding participant.")
            dashboardForm.addOnlineParticipant(participant)
        }

        Dashboard {
            id: dashboardForm
            anchors.fill: parent

            onButtonClicked: function() {
                // Hide dashboard
                UserClient.disconnect();
            }
        }
    }

    Item {
        id: signalReceiver
        function onOnlineParticipantsAnswer(participantList) {
            console.log("QML onOnlineParticipantsAnswer", participantList, participantList.length)
            for (var i = 0; i < participantList.length; i++)
            {
                var myObject = participantList[i]
                console.log("QML participant info", myObject)
                dashboardView.addOnlineParticipant(myObject)
            }
         }
    }


    Timer {
        id: getParticipantsTimer
        interval: 5000
        running: false
        repeat: true

        onTriggered: function() {
            if (UserClient.isConnected())
            {
                console.log("getParticipantsTimer");

            }
        }
    }

    Timer {
        id: getUsersTimer
        interval: 5000
        running: false
        repeat: true

        onTriggered: function() {
            if (UserClient.isConnected())
            {
                console.log("getUsersTimer");

            }
        }
    }

    Timer {
        id: getDevicesTimer
        interval: 5000
        running: false
        repeat: true

        onTriggered: function() {
            if (UserClient.isConnected())
            {
                console.log("getDevicesTimer");
            }
        }          
    }*/

    /*
    function onOnlineParticipantsAnswer(participantList) {
        console.log("QML onOnlineParticipantsAnswer", participantList, participantList.length)
        for (var i = 0; i < participantList.length; i++)
        {
            var myObject = participantList[i]
            console.log("QML participant info", myObject)
            //dashboardView.addOnlineParticipant(myObject)
        }
     }
     */





/*
    InputPanel {
        id: inputPanel
        property bool showKeyboard :  active
        y: showKeyboard ? parent.height - height : parent.height
        Behavior on y {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
        anchors.leftMargin: parent.width/10
        anchors.rightMargin: parent.width/10
        anchors.left: parent.left
        anchors.right: parent.right

    }
 */
}

