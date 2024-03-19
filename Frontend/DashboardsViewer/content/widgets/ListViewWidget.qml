import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Effects
import "../ui"

BaseWidget {

    id: myListViewWidget
    //Set model and delegate properties externally
    property alias delegate: myListView.delegate
    property var dataSource: null

    // Define a ListView to display the items
    ListView {
        id: myListView
        anchors.fill: parent
        spacing: 1
        clip: true
        focus: true
        model: dataSource ? dataSource.model : null
        currentIndex: -1

        property string fieldDisplayName: dataSource.fieldDisplayName
        property string fieldIdName: dataSource.fieldIdName
        property string iconPath: dataSource.iconPath

        ScrollBar.vertical: FlickableScrollBar {}

    }

}
