

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    property alias button: button
    property alias username: inputUsername.text
    property alias password: inputPassword.text
    property alias infoText: textArea.text

    anchors.fill: parent
    visible: true
    border.color: "#dc1010"
    width: 800
    height: 600

    Column {
        id: login_password_column
        spacing: 10
        anchors.fill: parent

        Text {
            id: fixedWelcomeText
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Opentera Dashboards Login")
            font.pixelSize: 60
        }

        Text {
            id: username
            height: 40
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Username")
            font.pixelSize: 28
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            id: inputUsernameRectangle
            anchors.horizontalCenter: parent.horizontalCenter
            border.color: "#3a1212"
            width: 300
            height: 50

            TextInput {
                id: inputUsername
                anchors.fill: parent
                font.pixelSize: 28
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                selectedTextColor: "#941b1b"
                maximumLength: 20
                focus: true
                KeyNavigation.tab: inputPassword
            }
        }

        Text {
            id: password
            anchors.horizontalCenter: parent.horizontalCenter
            height: 50
            text: qsTr("Password")
            font.pixelSize: 28
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            id: inputPasswordRectangle
            anchors.horizontalCenter: parent.horizontalCenter
            border.color: "#3a1212"
            width: 300
            height: 50

            TextInput {
                id: inputPassword
                anchors.fill: parent
                font.pixelSize: 28
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WrapAnywhere
                echoMode: TextInput.Password
                maximumLength: 20
                KeyNavigation.tab: button
            }
        }

        Button {
            id: button
            width: 100
            height: 50
            enabled: true
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Login")
        }

        TextArea {
            id: textArea
            anchors.horizontalCenter: parent.horizontalCenter
            width: 500
            height: 200
            visible: true
            placeholderText: qsTr("")
        }
    }
}
