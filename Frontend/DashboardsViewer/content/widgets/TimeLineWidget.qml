import QtQuick 2.15
import QtQuick.Controls 2.15
import DashboardsViewer 1.0
import "../dataSources"


BaseWidget {

    property ParticipantSessionListDataSource dataSource: null

    visible: dataSource !== null && dataSource.model && dataSource.model.count > 0

    property real totalDuration: 0
    property real startTimestamp: 0

    property string startTimeField: "session_start_datetime"
    property string durationField: "session_duration"
    property string colorField: "session_type_color"
    property string statusField: "session_status"

    Connections{
        ignoreUnknownSignals: true
        target: dataSource
        onModelChanged: function() {
            repeaterSessions.model = [];
            if (dataSource.model.count < 1){
                startTimestamp = 0;
                totalDuration = 0;
                return;
            }
            let endDateTime = new Date(dataSource.model.get(0)[startTimeField]);
            endDateTime.setHours(0);
            endDateTime.setMinutes(0);
            endDateTime.setSeconds(0);
            endDateTime.setMilliseconds(0);
            endDateTime.setDate(endDateTime.getDate() + 1);
            let end_timestamp = Math.floor(endDateTime.getTime() / 1000);//Math.ceil((Date.parse(dataSource.model.get(0)[startTimeField]) + dataSource.model.get(0)[durationField] * 1000) / 1000);

            let startDateTime = new Date(dataSource.model.get(dataSource.model.count-1)[startTimeField]) //Math.ceil((Date.parse(dataSource.model.get(dataSource.model.count-1)[startTimeField])) / 1000);
            startDateTime.setHours(0);
            startDateTime.setMinutes(0);
            startDateTime.setSeconds(0);
            startDateTime.setMilliseconds(0);
            startTimestamp = Math.floor(startDateTime.getTime() / 1000);
            totalDuration = end_timestamp - startTimestamp;

            // Force and set session repeater, as we want to have variables set beforehand
            repeaterSessions.model = dataSource.model;

            var days = Math.ceil(totalDuration / (3600 * 24));
            repeaterDays.model = days;

        }
    }

    function updateTimeline(){

    }

    Rectangle{
        anchors.fill: parent
        color: "black"

        Rectangle{
            id: recBase
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            height: 2* parent.height / 3
            color: "darkred"
            radius: 2

            Repeater{
                id: repeaterSessions
                model: []

                Rectangle{
                    property real relativeStartTimestamp: Math.floor(new Date(model[startTimeField]).getTime() / 1000) - startTimestamp
                    color: model[colorField] ? model[colorField] : "cyan"
                    border.color: "black"
                    border.width: 1
                    height: recBase.height
                    x: Math.floor((relativeStartTimestamp / totalDuration) * recBase.width)
                    width: Math.max(5, (model[durationField] / totalDuration) * recBase.width)
                    opacity: model[statusField] === 2 ? 1.0 : (model[statusField] === 1 ? 0.75 : 0.5)
                    /*onXChanged: {
                        console.log(Date.parse(model[startTimeField]) / 1000 + " - " + startTimestamp + " = " + relativeStartTimestamp + ", w=" + recBase.width + ", x=" + x);
                    }*/
                }
            }

            Repeater{
                id: repeaterDays
                model: []

                Rectangle{
                    required property int index
                    color: "white"
                    width: 1
                    x: ( index / repeaterDays.model) * recBase.width
                    height: recBase.height

                }
            }
        }

        Repeater{
            id: repeaterDates
            model: repeaterDays.model

            Label{
                required property int index
                x: ( index / repeaterDates.model) * recBase.width + recBase.x
                y: recBase.height + recBase.y + 5
                visible: repeaterDates.model <= 10 || index === 0 || index === repeaterDates.model
                text: visible ? new Date(dataSource.model.get(index)[startTimeField]).toDateString() : ""
            }
        }
    }
}
