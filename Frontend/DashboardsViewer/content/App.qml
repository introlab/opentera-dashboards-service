import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts

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

    property string contextText: ""

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

        RowLayout{
            anchors.fill: parent
            //Back button
            BasicButton {
                id: btnBack
                text: qsTr("Back")
                /*color: "darkred"
                hoverColor: "red"*/

                visible: stackview.depth > 2

                //height: parent.height
                onClicked: function () {
                    stackview.pop()
                }
            }
            Text {
                id: txtContext
                Layout.leftMargin: 10
                text: contextText
                visible: stackview.depth > 2 && contextText
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                color: Constants.textAltColor
            }

            Item{
                Layout.fillWidth: true
            }

            //Login username
            Text {
                id: username
                Layout.rightMargin: 10
                text: "username"
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                color: "white"
            }

            //Logout button
            BasicButton {
                id: logoutButton
                text: qsTr("Logout")
                color: "darkred"
                hoverColor: "red"


                onClicked: {
                    UserClient.disconnect();
                }
            }
        }
    }


    StackView {
        id: stackview
        initialItem: null
        anchors.top: menu.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Component.onCompleted: {
            if (UserClient.isWebAssembly())
            {
                stackview.push("screens/LoginWithToken.qml", {}, StackView.Immediate);
            }
            else
            {
                stackview.push("screens/Login.qml");
            }
        }
    }

    Connections {
        target: UserClient
        onLogoutSucceeded: function() {
            stackview.pop(null)
            menu.visible = false;
            if (UserClient.isWebAssembly())
            {
                stackview.push("screens/Logout.qml");
            }
            else
            {
                stackview.push("screens/Login.qml");
            }
        }
        onWebsocketDisconnected: function() {
            if (!UserClient.isWebAssembly())
            {
                stackview.pop(null)
            }
            menu.visible = false;
        }
    }

    /*Connections {
        target: UserClient
        onUserEvent: function(event) {
            console.log("UserEvent: ", event)
        }
    }*/
}

