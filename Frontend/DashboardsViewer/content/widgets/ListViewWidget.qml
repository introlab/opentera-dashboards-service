import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    width: 400
    height: 400

    //Set model and delegate properties externally
    property alias model: myListView.model
    property alias delegate: myListView.delegate

    // Define a ListView to display the items
    ListView {
        id: myListView
        anchors.fill: parent
        model: myModel
        delegate: myDelegate
    }

    ListModel {
        id: myModel
        ListElement { name: "Apple" }
        ListElement { name: "Banana" }
        ListElement { name: "Cherry" }
    }

    Component {
        id: myDelegate
        Text {
            text: name
        }
    }
}
