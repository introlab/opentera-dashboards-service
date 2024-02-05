

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    width: 1024
    height: 768

    property alias button: button
    property alias flow_view: flow_view

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
        id: button
        anchors.left: parent.left
        anchors.top: parent.top
        width: 150
        height: 60
        text: qsTr("Logout")
    }

    Flow {
        id: flow_view
        spacing: 10
        anchors.top: dashboardText.bottom
        anchors.bottom: parent.bottom
        width: parent.width
    }
}
