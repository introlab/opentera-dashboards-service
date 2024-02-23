import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    width: 400
    height: 400

    property alias model: myListView.model
    property alias delegate: myListView.delegate

    // Define a ListView to display the items
    ListView {
        id: myListView
        anchors.fill: parent
        model: myModel
        delegate: myDelegate
    }
}
