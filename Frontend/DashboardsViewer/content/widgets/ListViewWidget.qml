import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Effects

import DashboardsViewer 1.0
import "../ui"

BaseWidget {

    id: myListViewWidget
    //Set model and delegate properties externally
    property alias delegate: myListView.delegate
    property var dataSource: null

    readonly property bool itemSelected: myListView.currentIndex >= 0

    Connections{
        ignoreUnknownSignals: true
        target: dataSource
        onModelChanged: function() {
            myListView.currentIndex = -1;
        }
    }

    Rectangle{
        anchors.fill: parent
        color: "#88000000"
        radius: 4
    }

    Text{
        id: lblTitle
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 15
        visible: title !== ""
        text: title
        font.pixelSize: Constants.largeFontSize
        color: Constants.highlightColor
        wrapMode: Text.WordWrap
    }

    // Define a ListView to display the items
    ListView {
        id: myListView
        anchors.fill: parent
        anchors.topMargin: lblTitle.visible ? lblTitle.height + lblTitle.anchors.margins*2 : 5
        spacing: 1
        clip: true
        focus: true
        model: dataSource ? dataSource.model : null
        currentIndex: -1

        interactive: contentHeight > height

        property string fieldDisplayName: dataSource.fieldDisplayName
        property string fieldIdName: dataSource.fieldIdName
        property string iconPath: dataSource.iconPath

        ScrollBar.vertical: FlickableScrollBar {}

    }

}
