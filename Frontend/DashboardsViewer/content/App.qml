import QtQuick 6.2
import QtQuick.VirtualKeyboard 6.2
import QtQuick.Controls 6.2

import DashboardsViewer
import "screens"
import "ui"

import DashboardsViewer.ConfigParser 1.0
import OpenTeraLibs.UserClient 1.0

Window {
    width: Constants.width
    height: Constants.height

    visible: true
    title: "DashboardsViewer"
    id: mainWindow



    Rectangle{
        id: background
        anchors.fill: parent
        gradient: Gradient {
                GradientStop { position: 0.0; color: Constants.backgroundColor }
                GradientStop { position: 0.5; color: Constants.lightBackgroundColor }
                GradientStop { position: 1.0; color: Constants.backgroundColor }
            }
    }

    Rectangle {
        property alias displayUsername: username.text
        id: menu
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.left: parent.left
        height: 50
        visible: false

        gradient: Gradient {
                GradientStop { position: 0.0; color: Constants.backgroundColor }
                GradientStop { position: 0.5; color: Constants.lightBackgroundColor }
                GradientStop { position: 1.0; color: Constants.backgroundColor }
        }

        //Login username
        Text {
            id: username
            text: "username"
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: "white"
        }

        //Logout button
        BasicButton {
            id: logoutButton
            text: "Logout"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            color: "darkred"
            hoverColor: "red"
            width: 100
            //height: parent.height
            onClicked: {
                UserClient.disconnect();
            }
        }
    }


    StackView {
        id: stackview
        initialItem: Login {}
        anchors.top: menu.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    Connections {
        target: UserClient
        onLogoutSucceeded: function() {
            stackview.pop(null)
            menu.visible = false;
        }
    }
}

