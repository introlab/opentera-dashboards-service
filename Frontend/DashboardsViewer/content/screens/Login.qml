import QtQuick 2.15
import DashboardsViewer

import OpenTeraLibs.UserClient

LoginForm {

    function do_login() {
        if (!btnLogin.enabled)
            return;

        console.log("Initating login to ", AppURL);
        /*infoText.text = qsTr("Logging in...");
        infoText.color = "lightgreen"*/
        state = "logging";
        UserClient.connect(AppURL, username, password);
    }

    function clear() {
        username = "";
        password = "";
        state = "";
    }

    Component.onCompleted: {
        fieldUsername.forceActiveFocus();
    }

    onVisibleChanged: {
        if (!visible)
            clear();
    }

    //anchors.fill: parent
    Keys.enabled: true
    Keys.onReturnPressed: function() {
        do_login();
    }

    btnLogin.onClicked: function() {
        do_login();
    }

    Connections {
        target: UserClient
        onLoginSucceeded: function() {
            state = "loginSuccess";

            //Query user information
            var reply = UserClient.get("/api/user/users", {"self": true});

            reply.requestSucceeded.connect(function(response, statusCode) {
                console.log("Success", response, statusCode);
                var userInfo = response[0];
                menu.displayUsername = userInfo.user_firstname + " " + userInfo.user_lastname;
            });

            menu.visible = true;
            stackview.push("DashboardSelector.qml");
        }
        onLoginFailed: function(error) {
            infoText = error;
            state = "loginError";
        }
    }
}
