import QtQuick 2.15
import DashboardsViewer

Item {
    id: root
    property Item layout: null

    Component.onCompleted: function() {
        if (layout === null) {
            /*
            layout = DashboardsViewer.createLayout()
            layout.loadLayout("qrc:/layouts/DefaultLayout.json")
            layout.show()
            */
        }
        else {
           parent = layout
        }
    }
}
