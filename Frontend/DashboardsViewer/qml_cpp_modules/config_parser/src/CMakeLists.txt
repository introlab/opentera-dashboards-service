find_package(Qt6 6.2 REQUIRED COMPONENTS Core Gui Qml LinguistTools Quick)

set(dashboardviewer_qml_cpp_modules_config_parser_headers
    ConfigParser.h
)

set(dashboardviewer_qml_cpp_modules_config_parser_srcs
    ConfigParser.cpp
)

qt_add_qml_module(dashboardviewer_qml_cpp_modules_config_parser_qml
    URI "DashboardsViewer.ConfigParser"
    VERSION 1.0
    STATIC
    OUTPUT_DIRECTORY ${QT_QML_OUTPUT_DIRECTORY}/DashboardsViewer/ConfigParser
    SOURCES ${dashboardviewer_qml_cpp_modules_config_parser_headers} ${dashboardviewer_qml_cpp_modules_config_parser_srcs}
)
target_link_libraries(dashboardviewer_qml_cpp_modules_config_parser_qml PUBLIC Qt${QT_VERSION_MAJOR}::Core  Qt${QT_VERSION_MAJOR}::Qml)
target_include_directories(dashboardviewer_qml_cpp_modules_config_parser_qml PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
