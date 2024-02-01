import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Effects

import DashboardsViewer

Item {

    property alias btnLogin: btnLogin
    property alias username: inputUsername.text
    property alias password: inputPassword.text
    property alias infoText: lblInfo

    Rectangle {
        id: recBackground

        anchors.centerIn: parent
        height: layoutMain.implicitHeight + layoutMain.anchors.margins * 2
        width: layoutMain.implicitWidth + layoutMain.anchors.margins * 2
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
                source: "images/logos/LogoOpenTera.png"
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
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            Rectangle {
                id: recInputUsername
                border.color: "#3a1212"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                height: inputUsername.implicitHeight + 20

                TextInput {
                    id: inputUsername
                    anchors.fill: parent
                    font.pixelSize: Constants.baseFontSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    selectByMouse: true
                    selectedTextColor: "#941b1b"
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
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            Rectangle {
                id: recInputPassword
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                border.color: "#3a1212"
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
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

            Button {
                id: btnLogin
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.fillWidth: true

                Layout.minimumHeight: recInputPassword.height
                Layout.leftMargin: 10
                Layout.rightMargin: 10

                enabled: username && password
                text: qsTr("Login")
            }

            Text {
                id: lblInfo
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.fillHeight: true
                Layout.fillWidth: true

                color: Constants.textColor
                text: qsTr("Welcome! Please login.")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
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
