import QtQuick 2.15
import DashboardsViewer

import OpenTeraLibs.UserClient

LoginForm {

    function do_login() {
        console.log("Initating login to ", AppURL);
        infoText.text = qsTr("Logging in...");
        infoText.color = "lightgreen"
        UserClient.connect(AppURL, username, password);
    }

    function clear() {
        username = "";
        password = "";
        infoText.text = qsTr("Welcome! Please login.");
        infoText.color = Constants.textColor;
    }

    onVisibleChanged: {
        if (!visible)
            clear();
    }

    //anchors.fill: parent
    Keys.enabled: true
    Keys.onEnterPressed: function() {
        do_login();
    }

    btnLogin.onClicked: function() {
        do_login();
    }

    Connections {
        target: UserClient
        onLoginSucceeded: function() {
            infoText.text = qsTr("Welcome") + " " + username + "!";
            infoText.color = Constants.textColor;
        }
        onLoginFailed: function(error) {
            infoText.text = error;
            infoText.color = "red";
        }
    }
}
