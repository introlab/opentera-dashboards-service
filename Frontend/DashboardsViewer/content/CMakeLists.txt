qt_add_library(content STATIC)
qt6_add_qml_module(content
    URI "content"
    VERSION 1.0
    RESOURCE_PREFIX "/qt/qml"
    QML_FILES
        # App
        App.qml
        # Screens
        screens/Dashboard.qml
        screens/DashboardForm.ui.qml
        screens/DashboardSelector.qml
        screens/DashboardSelectorForm.ui.qml
        screens/Login.qml
        screens/LoginForm.ui.qml
        # Uis
        ui/BasicButton.ui.qml
        ui/BasicDialog.qml
        ui/FlickableScrollBar.qml
        # Widgets
        widgets/BaseWidget.qml
        widgets/ClockWidget.qml
        widgets/ButtonWidget.qml
        widgets/ListViewWidget.qml
        # Layouts
        layouts/BaseLayout.qml
        layouts/CenteredRowLayout.qml
        layouts/FlowLayout.qml
        # DataSources
        dataSources/BaseDataSource.qml
        dataSources/FetchDataSource.qml
        dataSources/ParticipantListDataSource.qml
        dataSources/ParticipantSessionListDataSource.qml
        # Delegates
        delegates/ParticipantDelegate.qml

    RESOURCES
        fonts/Arimo-VariableFont_wght.ttf
        images/logos/LogoOpenTera.png

)
