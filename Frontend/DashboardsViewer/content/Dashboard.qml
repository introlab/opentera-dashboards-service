import QtQuick 2.15

DashboardForm {

    signal buttonClicked()

    button.onClicked: function() {
        console.log("Logout Button Pressed")
        buttonClicked()
    }
}
