import QtQuick 2.15

import OpenTeraLibs.UserClient

DashboardSelectorForm {

    btnOK.onClicked:{
        stackView.push("Dashboard.qml")
    }

}
