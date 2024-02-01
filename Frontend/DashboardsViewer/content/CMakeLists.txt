qt_add_library(content STATIC)
qt6_add_qml_module(content
    URI "content"
    VERSION 1.0
    RESOURCE_PREFIX "/qt/qml"
    QML_FILES
        App.qml
        Login.qml
        Dashboard.qml
        DashboardForm.ui.qml
        OnlineParticipant.qml
        OnlineParticipantForm.ui.qml
        LoginForm.ui.qml

    RESOURCES
        fonts/Arimo-VariableFont_wght.ttf

        images/logos/LogoOpenTera.png
)
