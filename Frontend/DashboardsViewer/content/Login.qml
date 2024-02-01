import QtQuick 2.15
import DashboardsViewer

import OpenTeraLibs.UserClient

LoginForm {


    function login_button_pressed() {
        console.log("Button Pressed");
        console.log("Trying to reach QML Singleton UserClient Should return false");
        console.log(UserClient.isConnected());
        console.log("AppUrl", AppURL);
        UserClient.connect(AppURL, username, password);
    }

    anchors.fill: parent
    Keys.enabled: true
    Keys.onEnterPressed: function() {
        login_button_pressed();
    }

    button.onClicked: function() {
        login_button_pressed();
    }

    Connections {
        target: UserClient
        onLoginSucceeded: function() {
            console.log("login success!");
        }
        onLoginFailed: function(error) {
            console.log("login failed with error : ", error);
            infoText = error;
        }
    }
}
