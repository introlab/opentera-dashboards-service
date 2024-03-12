

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 2.15
import QtQuick.Controls 2.15
import DashboardsViewer

Item {
    width: 1024
    height: 768
    anchors.fill: parent

    property alias logoutButton: logoutButton
    property alias loadButton: loadButton
    property alias closeButton: closeButton
    property alias mainView: dashboardStackView
    property alias dashboardStackView: dashboardStackView

    Text {
        id: dashboardText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        text: qsTr("DASHBOARD")
        font.pixelSize: 60
        height: 60
        horizontalAlignment: Text.AlignHCenter
    }

    Button {
        id: logoutButton
        anchors.left: parent.left
        anchors.top: parent.top
        width: 150
        height: 60
        text: qsTr("Logout")
    }

    Button {
        id: loadButton
        anchors.left: logoutButton.right
        anchors.top: parent.top
        width: 150
        height: 60
        text: qsTr("Load")
    }

    Button {
        id: closeButton
        anchors.left: loadButton.right
        anchors.top: parent.top
        width: 150
        height: 60
        text: qsTr("Close")
    }

    StackView {
        id: dashboardStackView
        anchors.top: dashboardText.bottom
        anchors.bottom: parent.bottom
        width: parent.width
    }
}
