find_package(Qt6 6.2 REQUIRED COMPONENTS Core)


qt_add_library(dashboardsviewer_resources STATIC)
qt6_add_qml_module(dashboardsviewer_resources
    URI "DashboardsViewer.resources"
    VERSION 1.0
    RESOURCE_PREFIX "/dashboards"
    NO_PLUGIN
    RESOURCES
        json/TestDashboard.json
)
