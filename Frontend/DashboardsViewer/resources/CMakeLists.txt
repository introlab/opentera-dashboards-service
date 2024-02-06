find_package(Qt6 6.2 REQUIRED COMPONENTS Core)


SET(qrcs
   DashboardsViewerApp.qrc
)

qt_add_resources(dashboardsviewerapp_qrcs ${qrcs})

qt_add_library(dashboardsviewer_resources STATIC
  ${dashboardsviewerapp_qrcs}
)
