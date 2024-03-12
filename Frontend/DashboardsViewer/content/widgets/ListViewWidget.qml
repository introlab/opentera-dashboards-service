import QtQuick 2.15
import QtQuick.Controls 2.15



BaseWidget {

    id: myListViewWidget
    //Set model and delegate properties externally
    property alias delegate: myListView.delegate
    property var dataSource: null

    // Define a ListView to display the items
    ListView {
        id: myListView
        anchors.fill: parent
        model: dataSource ? dataSource.model : null

        property string fieldDisplayName: dataSource.fieldDisplayName
        property string fieldIdName: dataSource.fieldIdName
        property string iconPath: dataSource.iconPath

    }

}
