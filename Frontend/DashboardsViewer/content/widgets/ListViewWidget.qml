import QtQuick 2.15
import QtQuick.Controls 2.15



BaseWidget {

    //Set model and delegate properties externally
    property alias model: myListView.model
    property alias delegate: myListView.delegate
    property var dataSource: Object()


    // Define a ListView to display the items
    ListView {
        id: myListView
        anchors.fill: parent
        model: myModel
        delegate: myDelegate

        onModelChanged: function()
        {
            //At this stage the model is empty
        }

        onCountChanged: function()
        {
            //Something added to the model
            //Update all delegate to model items
            for (var i = 0; i < myListView.count; ++i) {
                var element = model.get(i); // Access the ListElement at index i
                var item = myListView.itemAtIndex(i);

                // Data Source will determine field names
                var fieldIdName = dataSource.fieldIdName;
                var fieldDisplayName = dataSource.fieldDisplayName;
                var iconPath = dataSource.iconPath;


                //TODO not working yet.
                /*
                item[fieldIdName] = element[fieldIdName];
                item[fieldDisplayName] = element[fieldDisplayName];
                item[iconPath] = element[iconPath];
                */

                console.log("Item at index", i, ":", item, element);
            }

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
