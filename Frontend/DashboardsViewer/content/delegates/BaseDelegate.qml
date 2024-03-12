import QtQuick 2.15

Item {
    id: baseDelegate
    property Item stackView: dashboardStackView ? dashboardStackView : null
}
