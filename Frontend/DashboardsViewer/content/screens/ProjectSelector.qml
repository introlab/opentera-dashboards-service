import QtQuick 2.15

ProjectSelectorForm {
    btnOK.onClicked:{
        stackview.push("Dashboard.qml");
    }
}
