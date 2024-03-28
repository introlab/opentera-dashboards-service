import QtQuick 2.15
import QtQuick.Controls 2.15
import DashboardsViewer 1.0
import "../dataSources"


BaseWidget {

    property ParticipantSessionListDataSource dataSource: null

    visible: dataSource !== null && dataSource.model && dataSource.model.count > 0

    property real totalDuration: 0
    property real startTimestamp: 0

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
            let end_timestamp = Math.ceil((Date.parse(dataSource.model.get(0).session_start_datetime) + dataSource.model.get(0).session_duration * 1000) / 1000);
            startTimestamp = Math.ceil((Date.parse(dataSource.model.get(dataSource.model.count-1).session_start_datetime)) / 1000);
            totalDuration = end_timestamp - startTimestamp;
            //console.log(dataSource.model.get(0).id_session + " * " +dataSource.model.get(dataSource.model.count-1).id_session + " / start: " + startTimestamp + ", total: " + totalDuration);
            //console.log(dataSource.model.get(0).session_start_datetime + " - " + dataSource.model.get(dataSource.model.count-1).session_start_datetime + " : " + totalDuration);

            // Force and set session repeater, as we want to have variables set beforehand
            repeaterSessions.model = dataSource.model;
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
                    property real relativeStartTimestamp: Math.ceil(Date.parse(model.session_start_datetime) / 1000) - startTimestamp
                    color: model.session_type_color ? model.session_type_color : "cyan"
                    border.color: "black"
                    border.width: 1
                    height: recBase.height
                    x: Math.ceil((relativeStartTimestamp / totalDuration) * recBase.width)
                    width: Math.max(5, (model.session_duration*1000 / totalDuration) * recBase.width)
                    opacity: model.session_status === 2 ? 1.0 : (model.session_status === 1 ? 0.75 : 0.5)
                }
            }
        }
    }
}
