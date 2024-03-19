import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15

import DashboardsViewer

BaseDelegate {
    id: myDelegate
    height: parent ? Math.min(100, mainLayout.implicitHeight + mainLayout.anchors.margins*2) : 0
    width: parent ? parent.width : 0

    property int daysWarningThreshold: 2
    property int daysErrorThreshold: 4

    property bool isCurrentItem: ListView ? ListView.isCurrentItem : false

    states: [
        State{
          name: "good"
          PropertyChanges {
              target: imgParticipant
              source: "../images/icons/patient_green.png"
          }
        },

        State {
            name: "warning"
            PropertyChanges {
                target: imgParticipant
                source: "../images/icons/patient_yellow.png"
            }
            PropertyChanges {
                target: txtName
                styleColor: "darkblue"
            }
        },
        State {
            name: "error"
            PropertyChanges {
                target: imgParticipant
                source: "../images/icons/patient_red.png"
            }
            PropertyChanges {
                target: txtName
                styleColor: "darkred"
            }
        }
    ]

    Component.onCompleted: function() {
        // Look for last_session
        if (model.participant_lastsession) {
            var lastSession = new Date(model.participant_lastsession)
            if (lastSession) {
                var now = new Date()
                var diff = now - lastSession
                let warningDelta = daysWarningThreshold * 1000 * 60 * 60 * 24;
                let errorDelta = daysErrorThreshold * 1000 * 60 * 60 * 24;

                // Difference less than a day ?
                if (diff < warningDelta) {
                    state = "good";
                }
                else {
                    // Less than a week ?
                    if (diff < errorDelta) {
                        state = "warning";
                    }
                    else {
                        state = "error";
                    }
                }
            }
            else {
                console.log("Invalid date")

            }
        }
    }

    Rectangle {
        id: myRectangle
        anchors.fill: parent
        color: Constants.highlightColor
        opacity: 0.8
        border.color: isCurrentItem ? "lightgrey" : "black"
        border.width: isCurrentItem ? 5 : 1
        radius: 5
    }

    RowLayout{
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 5
        Image{
            id: imgParticipant
            source: "../images/icons/patient.png"
            fillMode: Image.PreserveAspectFit
            height: 48
            sourceSize.height: height
            width: height
            sourceSize.width: height
            opacity: model.participant_enabled ? 1.0 : 0.3
        }
        ColumnLayout{
            Layout.fillHeight: true
            Layout.fillWidth: true
            Text{
                id: txtName
                Layout.fillWidth: true
                text: participant_name
                font.pixelSize: Constants.baseFontSize*1.2
                wrapMode: Text.WordWrap
                style: Text.Outline
                color: Constants.textColor
            }
            RowLayout{
                Layout.fillHeight: true
                Layout.fillWidth: true
                Text{
                    text: qsTr("Last session") + ":"
                    font.pixelSize: Constants.smallFontSize
                    wrapMode: Text.WordWrap
                }
                Text{
                    color: Constants.textAltColor
                    Layout.fillWidth: true
                    text: new Date(model.participant_lastsession).toLocaleDateString()
                    font.pixelSize: Constants.smallFontSize
                    style: Text.Outline
                    wrapMode: Text.Wrap
                }

            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            if (myDelegate.ListView)
                myDelegate.ListView.view.currentIndex = index;
            model.dataSource.itemSelected(model[model.dataSource.fieldIdName])
        }
    }

}
