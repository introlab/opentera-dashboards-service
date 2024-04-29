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
        screens/DashboardSelector.qml
        screens/LoadingScreen.qml
        screens/Login.qml

        # Uis
        ui/Badge.qml
        ui/BasicButton.ui.qml
        ui/BasicDialog.qml
        ui/FlickableScrollBar.qml

        # Widgets
        widgets/BaseWidget.qml
        widgets/ButtonWidget.qml
        widgets/ClockWidget.qml
        widgets/ImageButtonWidget.qml
        widgets/ListViewWidget.qml
        widgets/SessionViewerWidget.qml
        widgets/TimeLineWidget.qml

        # Layouts
        layouts/BaseLayout.qml
        layouts/CenteredColumnLayout.qml
        layouts/CenteredRowLayout.qml
        layouts/FlowLayout.qml

        # DataSources
        dataSources/BaseDataSource.qml
        dataSources/FetchDataSource.qml
        dataSources/FileDownloadDataSource.qml
        dataSources/ParticipantListDataSource.qml
        dataSources/ParticipantSessionListDataSource.qml
        dataSources/SessionEventListDataSource.qml

        # Delegates
        delegates/BaseDelegate.qml
        delegates/DashboardDelegate.qml
        delegates/GenericItemDelegate.qml
        delegates/ParticipantDelegate.qml
        delegates/SessionDelegate.qml
        delegates/SessionEventDelegate.qml

    RESOURCES
        fonts/Arimo-VariableFont_wght.ttf

        images/logos/LogoOpenTera.png

        images/icons/battery_charging.png
        images/icons/battery_full.png
        images/icons/battery_low.png
        images/icons/dashboard.png
        images/icons/data.png
        images/icons/device.png
        images/icons/error.png
        images/icons/flag.png
        images/icons/flag_red.png
        images/icons/info.png
        images/icons/join.png
        images/icons/leave.png
        images/icons/patient.png
        images/icons/patient_green.png
        images/icons/patient_yellow.png
        images/icons/patient_red.png
        images/icons/play.png
        images/icons/project.png
        images/icons/session.png
        images/icons/site.png
        images/icons/software_user.png
        images/icons/stop.png
        images/icons/storage_full.png
        images/icons/storage_low.png
        images/icons/warning.png
        images/icons/x.png
    )
