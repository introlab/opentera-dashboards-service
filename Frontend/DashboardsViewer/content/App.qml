// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick 6.2
import DashboardsViewer
import QtQuick.VirtualKeyboard 6.2
import QtQuick.Controls 6.2

Window {
    width: Constants.width
    height: Constants.height

    visible: true
    title: "DashboardsViewer"

    StackView {
        id: stackview
        initialItem: loginView
        anchors.fill: parent
    }

    Component {
        id: loginView      
        Login {
            id: loginForm
            anchors.fill: parent
        }
    }

    Component {
        id: dashboardView
        Dashboard {
            id: dashboardForm
            anchors.fill: parent

            onButtonClicked: function() {
                // Hide dashboard
                UserClient.disconnect();
            }
        }
    }

    Connections {

        function qmlObjectToDict(qmlObject) {
                var dict = {}
                for (var key in qmlObject) {
                    if (qmlObject.hasOwnProperty(key)) {
                        console.log(key, qmlObject[key])
                        dict[key] = qmlObject[key]
                    }
                }
                return dict
            }

        target: UserClient
        onLoginSucceeded: function() {
            console.log("login success!");

            //Show Dashboard
            stackview.push(dashboardView);
        }
        onLogoutSucceeded: function() {
            console.log("logout success!");
            stackview.pop()
        }
        onOnlineParticipants: function(results) {
           for (var i = 0; i < results.length; i++)
           {
               var myObject = results[i]
               console.log(i, " ", myObject["id_participant"])
           }
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

