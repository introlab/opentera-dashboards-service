import QtQuick 2.15

import OpenTeraLibs.UserClient

DashboardSelectorForm {

    btnOK.onClicked:{
        stackview.push("Dashboard.qml")

        // get current pushed element
        var currentElement = stackview.currentItem;

        // Set the element property
        currentElement.jsonFileName = fileName;
    }

}
