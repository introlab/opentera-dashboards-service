// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick 6.2
import DashboardsViewer
import QtQuick.VirtualKeyboard 6.2
import QtQuick.Controls 6.2

import OpenTeraLibs.UserClient 1.0

Window {
    width: Constants.width
    height: Constants.height

    visible: true
    title: "DashboardsViewer"
    id: mainWindow

    StackView {
        id: stackview
        initialItem: loginView
        anchors.fill: parent
    }

    Item {
        id: loginView
        visible: true
        Login {
            id: loginForm
            anchors.fill: parent
        }
    }

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
    }

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

    Connections {
        target: UserClient
        onLoginSucceeded: function() {
            console.log("login success!");

            //After login, test wapper
            var params = {};
            var headers = {};
            var wrapper = UserClient.get("/api/user/participants/online", params, headers);
            console.log("found wrapper", wrapper);

            wrapper.requestSucceeded.connect(
                                function(response) {
                                    console.log("Hello world!", response)
                                });



            //Show Dashboard
            stackview.push(dashboardView);

            getParticipantsTimer.running = true;
            getUsersTimer.running = true;
            getDevicesTimer.running = true;
        }
        onLogoutSucceeded: function() {
            console.log("logout success!");
            stackview.pop()

            getParticipantsTimer.running = false;
            getUsersTimer.running = false;
            getDevicesTimer.running = false;
        }
    }



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

