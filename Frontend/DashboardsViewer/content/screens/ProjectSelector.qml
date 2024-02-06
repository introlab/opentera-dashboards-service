import QtQuick 2.15

ProjectSelectorForm {
    btnOK.onClicked:{
        stackview.push("Dashboard.qml");

        // get current pushed element
        var currentElement = stackview.currentItem;

        // Set the element property
        currentElement.json_file_name = file_name;
    }
}
