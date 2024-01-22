

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    anchors.fill: parent

    property alias button: button

    Button {
        id: button
        width: 100
        height: 50
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        text: qsTr("Login")
    }

    Text {
        id: fixedWelcomeText
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Opentera Dashboards Login")
        font.pixelSize: 34
    }

    Text {
        id: username
        width: 300
        height: 50
        anchors.top: fixedWelcomeText.bottom
        topPadding: 10
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Username")
        font.pixelSize: 28
        horizontalAlignment: Text.AlignHCenter
    }

    TextInput {
        id: inputUsername
        anchors.top: username.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: 300
        height: 50
        font.pixelSize: 28
        horizontalAlignment: Text.AlignHCenter
        selectedTextColor: "#941b1b"
    }

    Text {
        id: password
        height: 50
        anchors.top: inputUsername.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Password")
        font.pixelSize: 28
        horizontalAlignment: Text.AlignHCenter
    }

    TextInput {
        id: inputPassword
        anchors.top: password.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: 300
        height: 50
        font.pixelSize: 28
        horizontalAlignment: Text.AlignHCenter
        echoMode: TextInput.Password
    }
}
