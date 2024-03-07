import QtQuick 2.15
import QtQuick.Controls 2.15



BaseWidget {

    //Set model and delegate properties externally
    property alias model: myListView.model
    property alias delegate: myListView.delegate


    // Define a ListView to display the items
    ListView {
        id: myListView
        anchors.fill: parent
        model: myModel
        delegate: myDelegate

        onModelChanged: function()
        {
            console.log("ListViewWidget.onModelChanged");
            delegate.fieldIdName = model.fieldIdName
            delegate.fieldDisplayName = model.fieldDisplayName;
            delegate.iconPath = model.iconPath;
        }
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
