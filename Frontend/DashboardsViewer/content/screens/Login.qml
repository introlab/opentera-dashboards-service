import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Effects

import OpenTeraLibs.UserClient

import DashboardsViewer
import "../ui"

Item {
    property string infoText: ""
    states: [
        State {
            name: "logging"
            PropertyChanges {
                target: lblInfo
                color: "lightgreen"
                text: qsTr("Logging in...")
            }
            PropertyChanges {
                target: inputUsername
                enabled: false
                opacity: 0.5
            }
            PropertyChanges {
                target: inputPassword
                enabled: false
                opacity: 0.5
            }
        },
        State {
            name: "loginSuccess"
            PropertyChanges {
                target: lblInfo
                color: Constants.textColor
                text: qsTr("Welcome!")
            }
        },
        State {
            name: "loginError"
            PropertyChanges {
                target: lblInfo
                color: "yellow"
                text: infoText
            }
        }
    ]

    function do_login() {
        if (!btnLogin.enabled)
            return

        console.log("Initating login to ", AppURL)

        state = "logging"
        UserClient.connect(AppURL, inputUsername.text, inputPassword.text)
    }

    function clear() {
        inputUsername.clear();
        inputPassword.clear();
        state = "";
    }

    Component.onCompleted: {
        inputUsername.forceActiveFocus()
    }

    onVisibleChanged: {
        if (!visible)
            clear()
    }

    //anchors.fill: parent
    Keys.enabled: true
    Keys.onReturnPressed: function () {
        do_login()
    }

    Connections {
        target: UserClient
        onLoginSucceeded: function() {
            state = "loginSuccess";

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
            infoText = error;
            state = "loginError";
        }
    }
    ////////////////////////

    Rectangle {
        id: recBackground

        anchors.centerIn: parent
        implicitHeight: layoutMain.implicitHeight + layoutMain.anchors.margins * 2
        implicitWidth: 400 // layoutMain.implicitWidth + layoutMain.anchors.margins * 2
        visible: true
        border.color: "grey"
        border.width: 2
        radius: 10
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Constants.lightBackgroundColor
            }
            GradientStop {
                position: 0.5
                color: Constants.highlightColor
            }
            GradientStop {
                position: 1.0
                color: Constants.lightBackgroundColor
            }
        }

        ColumnLayout {
            id: layoutMain
            spacing: 10
            anchors.fill: parent
            anchors.margins: 10

            Image {
                id: imgLogo
                source: "../images/logos/LogoOpenTera.png"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                fillMode: Image.PreserveAspectFit
                height: 200
                sourceSize.height: height
            }

            Text {
                id: txtUsername
                text: qsTr("Username")
                font.pixelSize: Constants.largeFontSize
                font.bold: true
                color: Constants.textColor
                horizontalAlignment: Text.AlignHCenter
                style: Text.Outline
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            Rectangle {
                id: recInputUsername
                border.color: "#3a1212"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Layout.topMargin: -parent.spacing
                height: inputUsername.implicitHeight + 20

                TextInput {
                    id: inputUsername
                    anchors.fill: parent
                    font.pixelSize: Constants.baseFontSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    selectByMouse: true
                    maximumLength: 20
                    focus: true
                    KeyNavigation.tab: inputPassword
                }
            }

            Text {
                id: txtPassword
                text: qsTr("Password")
                font.pixelSize: Constants.largeFontSize
                font.bold: true
                color: Constants.textColor
                horizontalAlignment: Text.AlignHCenter
                style: Text.Outline
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            Rectangle {
                id: recInputPassword
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                border.color: "#3a1212"
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Layout.topMargin: -parent.spacing
                height: inputPassword.implicitHeight + 20

                TextInput {
                    id: inputPassword
                    anchors.fill: parent
                    font.pixelSize: Constants.baseFontSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAnywhere
                    echoMode: TextInput.Password
                    selectByMouse: true
                    maximumLength: 20
                    KeyNavigation.tab: btnLogin
                }
            }

            BasicButton {
                id: btnLogin
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.fillWidth: true

                Layout.minimumHeight: recInputPassword.height
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Layout.topMargin: parent.spacing

                enabled: inputPassword.text  && inputUsername.text
                text: qsTr("Login")
                onClicked: function () {
                    do_login()
                }
            }

            Text {
                id: lblInfo
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.fillHeight: true
                Layout.fillWidth: true

                color: "cyan"
                text: qsTr("Welcome! Please login.")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                style: Text.Outline
                font.pixelSize: Constants.baseFontSize
            }
        }
    }
    MultiEffect {
        source: recBackground
        anchors.fill: source
        shadowEnabled: true
        shadowHorizontalOffset: 2
        shadowVerticalOffset: 2
    }
}
