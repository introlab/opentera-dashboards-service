import QtQuick 2.15
import OpenTeraLibs.UserClient
import "../dataSources"

DashboardSelectorForm {
    id:selectorForm

    btnOK.onClicked:{
        stackview.push("Dashboard.qml")

        // get current pushed element
        var currentElement = stackview.currentItem;

        // Set the element property
        currentElement.jsonFileName = fileName;
    }

    cmbSites.onCurrentIndexChanged: function() {

        console.log("cmbSites.onCurrentIndexChanged", cmbSites.currentIndex);
        var index = cmbSites.currentIndex;

        if (index >= 0) {
            //Get element at index
            var selectedSite = sitesDataSource.model.get(index);

            console.log(selectedSite);
            if (selectedSite && selectedSite.id_site)
            {
                projectsDataSource.setSiteID(selectedSite.id_site);
            }
        }
    }

    cmbProjects.onCurrentIndexChanged: function() {
        console.log("cmbProjects.onCurrentIndexChanged", cmbProjects.currentIndex);
        var index = cmbProjects.currentIndex;

        if (index >=0) {
            // Get Selected project
            var selectedProject = projectsDataSource.model.get(index);
            console.log(selectedProject);
            if (selectedProject && selectedProject.id_project)
            {
                //TODO Project Selection
            }
        }
    }


    BaseDataSource {
        id: sitesDataSource
        url: "/api/user/sites"
        params: {"list": true}
        autoFetch: true

        // Look for change in the model
        model.onCountChanged: function() {

            console.log("Sites model updated.")
            cmbSites.model.clear();

            for (var i = 0; i < model.count; ++i) {
                var site = model.get(i);
                cmbSites.model.append({"text": site.site_name});
            }

            // Select first element in combo ?
            if (model.count > 0)
            {
                cmbSites.currentIndex = 0;
            }
        }
    } // sitesDataSource

    BaseDataSource {
        id: projectsDataSource
        url: "/api/user/projects"
        property int id_site: -1
        params: {"id_site": id_site}
        autoFetch: false

        function setSiteID(id) {
            projectsDataSource.id_site = id;
            //Get all information
            getAll();
        }

        model.onCountChanged: function() {
            cmbProjects.model.clear();

            for (var i = 0; i < model.count; ++i) {
                var project = model.get(i);
                cmbProjects.model.append({"text": project.project_name});
            }

            // Select first element in combo?
            if(model.count > 0) {
                cmbProjects.currentIndex = 0;
            }

        }
    } // projectsDataSource
}
