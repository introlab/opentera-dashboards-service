import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15

import DashboardsViewer

BaseDelegate {
    id: myDelegate
    height: parent ? Math.min(100, mainLayout.implicitHeight + mainLayout.anchors.margins*2) : 0
    width: parent ? (parent.interactive ? parent.width - 20 : parent.width) : 0

    function getEventIcon(){
        if (model.id_session_event_type === undefined)
            return "../images/icons/error.png";
        switch(id_session_event_type){
        case 0: // Error
            return "../images/icons/error.png";
        case 2: // Warning
            return "../images/icons/warning.png";
        case 3: // Start
            return "../images/icons/play.png";
        case 4: // Stop
            return "../images/icons/stop.png";
        case 5: // On Charge
            return "../images/icons/battery_charging.png";
        case 6: // Off Charge
            return "../images/icons/battery_full.png";
        case 7: // Low battery
            return "../images/icons/battery_low.png";
        case 8: // Low storage
            return "../images/icons/storage_low.png";
        case 9: // Storage full
            return "../images/icons/storage_full.png";
        case 10: // Device event
            return "../images/icons/device.png";
        case 11: // User event
            return "../images/icons/software_user.png";
        case 12: // Session join
            return "../images/icons/join.png";
        case 13: // Session leave
            return "../images/icons/leave.png";
        case 14: // Session join refused
            return "../images/icons/x.png";
        default:
            return "../images/icons/flag.png";
        }
    }

    function getEventName(){
        if (model.id_session_event_type === undefined)
            return qsTr("Error");
        switch(id_session_event_type){
        case 0: // Error
            return qsTr("Error");
        case 2: // Warning
            return qsTr("Warning");
        case 3: // Start
            return qsTr("Session started");
        case 4: // Stop
            return qsTr("Session stopped");
        case 5: // On Charge
            return qsTr("Battery charging started")
        case 6: // Off Charge
            return qsTr("Battery charging stopped");
        case 7: // Low battery
            return qsTr("Battery low");
        case 8: // Low storage
            return qsTr("Storage low");
        case 9: // Storage full
            return qsTr("Storage full");
        case 10: // Device event
            return qsTr("Device event");
        case 11: // User event
            return qsTr("User event");
        case 12: // Session join
            return qsTr("Session joined");
        case 13: // Session leave
            return qsTr("Session left");
        case 14: // Session join refused
            return qsTr("Session refused");
        default:
            return qsTr("Other");
        }
    }

    Rectangle {
        id: myRectangle
        anchors.fill: parent
        color: "grey" //Constants.highlightColor
        opacity: 0.8
        radius: 5
    }

    RowLayout{
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 5
        Image{
            id: imgEvent
            source: getEventIcon()
            fillMode: Image.PreserveAspectFit
            height: 32
            sourceSize.height: height
            width: height
            sourceSize.width: height
        }
        ColumnLayout{
            Layout.fillHeight: true
            Layout.fillWidth: true
            Text{
                id: txtDate
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                property date eventDate: new Date(model.session_event_datetime)
                text: eventDate.toLocaleTimeString(Locale.ShortFormat)
                font.pixelSize: Constants.smallFontSize
                style: Text.Outline
                font.bold: true
                color: Constants.textAltColor
                wrapMode: Text.WordWrap
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
            Text{
                id: txtName
                Layout.fillWidth: true
                text: getEventName()
                font.pixelSize: Constants.baseFontSize
                wrapMode: Text.WordWrap
                style: Text.Outline
                color: Constants.textColor
            }
            Text{
                id: txtDesc
                Layout.fillWidth: true
                visible: text
                text: model.session_event_text ? model.session_event_text : ""
                font.pixelSize: Constants.smallFontSize
                wrapMode: Text.WordWrap
                color: "white"
            }
        }
    }

}
