import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Effects

import "../ui"
import "../delegates"
import "../dataSources"
import DashboardsViewer 1.0
import OpenTeraLibs.UserClient

Item {
    id: rootItem

    BaseDataSource {
        id: sitesDataSource
        url: "/api/user/sites"
        params: {
            "list": true
        }
        autoFetch: true

        // Look for change in the model
        model.onCountChanged: function () {

            console.log("Sites model updated.")
            cmbSites.model.clear()

            for (var i = 0; i < model.count; ++i) {
                var site = model.get(i)
                cmbSites.model.append({
                                          "text": site.site_name
                                      })
            }

            // Select first element in combo ?
            if (model.count > 0) {
                cmbSites.currentIndex = 0
            }
        }
    } // sitesDataSource

    BaseDataSource {
        id: projectsDataSource
        url: "/api/user/projects"
        property int id_site: -1
        params: {
            "id_site": id_site
        }
        autoFetch: false

        function setSiteID(id) {
            projectsDataSource.id_site = id
            //Get all information
            getAll()
        }

        model.onCountChanged: function () {
            cmbProjects.model.clear()

            for (var i = 0; i < model.count; ++i) {
                var project = model.get(i)
                cmbProjects.model.append({
                                             "text": project.project_name
                                         })
            }

            // Select first element in combo?
            if (model.count > 0) {
                cmbProjects.currentIndex = 0
            }
        }
    } // projectsDataSource

    BaseDataSource {
        id: sitesDashboardDataSource
        url: "/dashboards/api/user/dashboards"
        property int id_site: -1
        params: {
            "id_site": id_site
        }
        autoFetch: false

        function setSiteID(id) {
            sitesDashboardDataSource.id_site = id
            //Get all information
            getAll()
        }

        model.onCountChanged: function () {

            siteGridView.model.clear()
            for (var i = 0; i < model.count; ++i) {
                var dashboard = model.get(i)
                console.log(dashboard)

                var description = dashboard.dashboard_description
                var enabled = dashboard.dashboard_enabled
                var name = dashboard.dashboard_name
                var definition = dashboard.versions.dashboard_definition

                console.log(description, enabled, name, definition)

                siteGridView.model.append({
                                                           "id": dashboard.id_dashboard,
                                                           "name": name,
                                                           "definition": definition,
                                                           "color": "Blue"
                                                       })
            }
        }
    } // projectsDashboardDataSource

    BaseDataSource {
        id: projectsDashboardDataSource
        url: "/dashboards/api/user/dashboards"
        property int id_project: -1
        params: {
            "id_project": id_project
        }
        autoFetch: false

        function setProjectID(id) {
            projectsDashboardDataSource.id_project = id
            //Get all information
            getAll()
        }

        model.onCountChanged: function () {

            projectGridView.model.clear()

            for (var i = 0; i < model.count; ++i) {
                var dashboard = model.get(i)
                console.log(dashboard)

                var description = dashboard.dashboard_description
                var enabled = dashboard.dashboard_enabled
                var name = dashboard.dashboard_name
                var definition = dashboard.versions.dashboard_definition

                projectGridView.model.append({
                                                              "id": dashboard.id_dashboard,
                                                              "name": name,
                                                              "definition": definition,
                                                              "color": "Red"
                                                          })
            }
        }
    } // projectsDashboardDataSource

    anchors.centerIn: parent
    width: parent? 0.8 * parent.width : 400
    height: parent ? 0.9 * parent.height : 200

    BasicDialog {
        id: dlgMain
        title: qsTr("Select dashboard to display")
        anchors.fill: parent
        ColumnLayout {
            id: layoutMain
            anchors.fill: parent
            anchors.margins: 10

            Rectangle {
                Layout.fillWidth: true

                implicitHeight: rowFilters.implicitHeight + lblFilters.implicitHeight
                                + rowFilters.anchors.margins * 2

                radius: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                color: "#77000000"

                Text {
                    id: lblFilters
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.leftMargin: 10
                    text: qsTr("Filters")
                    color: "lightyellow"
                    font.pixelSize: Constants.smallFontSize
                    font.italic: true
                }

                RowLayout {
                    id: rowFilters
                    anchors.top: lblFilters.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 5
                    implicitHeight: 200

                    Text {
                        text: qsTr("Site")
                        Layout.leftMargin: 20
                        color: Constants.textColor
                        font.pixelSize: Constants.smallFontSize
                        font.bold: true
                        style: Text.Outline
                    }

                    ComboBox {
                        id: cmbSites
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: ListModel {}
                        onCurrentIndexChanged: function () {

                            var index = cmbSites.currentIndex

                            if (index >= 0) {
                                //Get element at index
                                var selectedSite = sitesDataSource.model.get(
                                            index)

                                if (selectedSite && selectedSite.id_site) {
                                    projectsDataSource.setSiteID(
                                                selectedSite.id_site)
                                    sitesDashboardDataSource.setSiteID(
                                                selectedSite.id_site)
                                }
                            } else {
                                siteGridView.model.clear()
                            }
                        }
                    }
                    Text {
                        text: qsTr("Project")
                        color: Constants.textColor
                        font.pixelSize: Constants.smallFontSize
                        style: Text.Outline
                        font.bold: true
                    }

                    ComboBox {
                        id: cmbProjects
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: ListModel {}
                        onCurrentIndexChanged: function () {
                            var index = cmbProjects.currentIndex

                            if (index >= 0) {
                                // Get Selected project
                                var selectedProject = projectsDataSource.model.get(
                                            index)
                                if (selectedProject
                                        && selectedProject.id_project) {
                                    projectsDashboardDataSource.setProjectID(
                                                selectedProject.id_project)
                                }
                            } else {
                                projectGridView.model.clear()
                            }
                        }
                    }
                } //RowLayout
            } // First Rect
            Rectangle {
                id: siteProjectGrids
                color: "#77000000"
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop

                RowLayout {
                    //Fill the rest
                    id: siteProjectRowLayout
                    anchors.fill: parent

                    GridView {
                        id: siteGridView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        cellWidth: 100
                        cellHeight: 100
                        clip: true
                        ScrollBar.vertical: FlickableScrollBar {}
                        model: ListModel {}
                        delegate: SiteProjectDelegate {
                            id: siteProjectDelegateSite

                            onItemClicked: function (id, definition) {
                                stackview.push("Dashboard.qml")

                                // Get the current pushed element (the Dashboard)
                                var currentElement = stackview.currentItem

                                // Set the Actual definition
                                currentElement.definition = definition
                                currentElement.loadDocument()
                            }
                        }
                    } // GridView 1

                    GridView {
                        id: projectGridView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: ListModel {}
                        cellWidth: 100
                        cellHeight: 100
                        clip: true

                        ScrollBar.vertical: FlickableScrollBar {}
                        delegate: SiteProjectDelegate {
                            id: siteProjectDelegateProject

                            onItemClicked: function (id, definition) {
                                stackview.push("Dashboard.qml")

                                // Get the current pushed element (the Dashboard)
                                var currentElement = stackview.currentItem

                                // Set the Actual definition
                                currentElement.definition = definition
                                currentElement.loadDocument()
                            }
                        }
                    } // GridView 2
                } //RowLayout (2)
            } // Rectangle 2
        } // ColumnLayout
    } // BasicDialog
} // Item
