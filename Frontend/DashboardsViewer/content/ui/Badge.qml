import QtQuick
import QtQuick.Controls
import QtQuick.Effects

import DashboardsViewer

Item {
    id: baseItem
    implicitWidth: recBackground.implicitWidth
    implicitHeight: recBackground.implicitHeight

    property alias color: recBackground.color
    property alias textColor: txtBadge.color
    property alias textAlign: txtBadge.horizontalAlignment
    property alias font: txtBadge.font
    property alias padding: txtBadge.padding
    required property string text

    Rectangle{
        id: recBackground
        radius: 5
        color: "blue"
        implicitHeight: txtBadge.implicitHeight + 10
        implicitWidth: txtBadge.implicitWidth + 15
        anchors.fill: parent
        Text {
            id: txtBadge
            anchors.fill: parent
            anchors.margins: 5
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: baseItem.text
            wrapMode: Text.WordWrap
            font.pixelSize: Constants.smallFontSize
            font.bold: true
            color: "white"
        }
    }
    MultiEffect{
        source: recBackground
        anchors.fill: source
        autoPaddingEnabled: true
        shadowEnabled: true
        shadowHorizontalOffset: 2
        shadowVerticalOffset: 2
        shadowColor: "black"
    }
}
