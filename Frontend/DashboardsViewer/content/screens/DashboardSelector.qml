import QtQuick 2.15

import OpenTeraLibs.UserClient

DashboardSelectorForm {

    btnOK.onClicked:{
        stackview.push("Dashboard.qml")
    }

}
