import QtQuick 2.15
import QtQuick.Controls 2.15
import DashboardsViewer 1.0
import "../dataSources"


BaseWidget {

    property ParticipantSessionListDataSource dataSource: null

    visible: dataSource !== null && dataSource.model && dataSource.model.count > 0

    implicitHeight: 130

    property real totalDuration: 0
    property real startTimestamp: 0

    property real datasetStartTimestamp: 0
    property real datasetEndTimestamp: 0

    property string startTimeField: "session_start_datetime"
    property string durationField: "session_duration"
    property string colorField: "session_type_color"
    property string statusField: "session_status"

    property bool reversedDates: false
    property var currentDataModel: []

    function addDays(date, days) {
      var result = new Date(date);
      result.setDate(result.getDate() + days);
      return result;
    }

    function getStartOfWeek(date)
    {
        var diff = date.getDate() - date.getDay();
        return new Date(date.setDate(diff));
    }

    function getEndOfWeek(date)
    {
        var diff = date.getDate() + (6-date.getDay());
        return new Date(date.setDate(diff));
    }

    function formatDate(date_to_format){
        var str_date = "";
        var day = date_to_format.getDate();
        var month = date_to_format.getMonth() + 1;
        var year = date_to_format.getFullYear();

        // dd-mm-yyyy format
        if (day < 10){
            str_date = "0"
        }
        str_date += day.toString() + "-";

        if (month < 10){
            str_date += "0";
        }
        str_date += month.toString() + "-";
        str_date += year.toString();

        // yyyy-mm-dd format
        /*str_date = year.toString() + "-";
        if (month < 10){
            str_date += "0";
        }
        str_date += month.toString() + "-";
        if (day < 10){
            str_date += "0"
        }
        str_date += day.toString()*/

        return str_date;
    }

    Connections{
        ignoreUnknownSignals: true
        target: dataSource
        onModelChanged: function() {
            console.log("*** Model changed");
            if (dataSource.model.count < 1){
                repeaterSessions.model = [];
                repeaterDays.model = [];
                startTimestamp = 0;
                totalDuration = 0;
                return;
            }
            // Fill combobox
            let early_index = reversedDates ? dataSource.model.count - 1 : 0;
            let later_index = reversedDates ? 0 : dataSource.model.count - 1;

            let endDateTime = getEndOfWeek(new Date(dataSource.model.get(later_index)[startTimeField]));
            endDateTime.setHours(0);
            endDateTime.setMinutes(0);
            endDateTime.setSeconds(0);
            endDateTime.setMilliseconds(0);
            endDateTime.setDate(endDateTime.getDate() + 1);
            datasetEndTimestamp = Math.floor(endDateTime.getTime() / 1000);

            let startDateTime = getStartOfWeek(new Date(dataSource.model.get(early_index)[startTimeField]));
            startDateTime.setHours(0);
            startDateTime.setMinutes(0);
            startDateTime.setSeconds(0);
            startDateTime.setMilliseconds(0);
            datasetStartTimestamp = Math.floor(startDateTime.getTime() / 1000);
            totalDuration = datasetEndTimestamp - datasetStartTimestamp;
            var days = Math.ceil(totalDuration / (3600 * 24));

            // Create combobox (weeks) model
            let weeks = [{label: qsTr("All"), value: ""}];
            let current_day = 0;
            let current_week = 1;
            while (current_day < days){
                let current_date = getStartOfWeek(addDays(startDateTime, current_day));
                weeks.push({label: qsTr("Week") + " #" + current_week.toString() + " (" + current_date.toLocaleDateString() + ")",
                            value: current_date});
                current_day += 7;
                current_week += 1;
            }
            cmbWeeks.model = weeks;
            cmbWeeks.currentIndex = cmbWeeks.count - 1;

            // Update current timeline display
            updateTimeline();

        }
    }

    function updateTimeline(){
        // Update timeline based on selected item in the combobox
        repeaterSessions.model = [];
        repeaterDays.model = [];

        // Extract sub-dataset from datasource
        if (cmbWeeks.currentValue === ""){ // All
            currentDataModel = dataSource.model;
        }else{
            let current_week_date = cmbWeeks.currentValue;
            let next_week_date = new Date(current_week_date);
            next_week_date = addDays(next_week_date, 7);
            currentDataModel = modelFiltered;
            currentDataModel.clear();
            // TODO: Optimize with indexes?
            for (let i=0; i<dataSource.model.count; i++){
                let current_date = new Date(dataSource.model.get(i)[startTimeField]);
                //console.log(current_date.toDateString());
                if (current_date >= current_week_date && current_date < next_week_date){
                    currentDataModel.append(dataSource.model.get(i));
                }
            }
        }

        if (currentDataModel.count === 0){
            repeaterSessions.model = [];
            repeaterDays.model = [];
            return;
        }

        let early_index = reversedDates ? currentDataModel.count - 1 : 0;
        let later_index = reversedDates ? 0 : currentDataModel.count - 1;

        var endDateTime;
        var startDateTime;

        endDateTime = getEndOfWeek(new Date(currentDataModel.get(later_index)[startTimeField]));
        startDateTime = getStartOfWeek(new Date(currentDataModel.get(early_index)[startTimeField]));

        endDateTime.setHours(0);
        endDateTime.setMinutes(0);
        endDateTime.setSeconds(0);
        endDateTime.setMilliseconds(0);
        endDateTime.setDate(endDateTime.getDate() + 1);
        let end_timestamp = Math.floor(endDateTime.getTime() / 1000);

        startDateTime.setHours(0);
        startDateTime.setMinutes(0);
        startDateTime.setSeconds(0);
        startDateTime.setMilliseconds(0);
        startTimestamp = Math.floor(startDateTime.getTime() / 1000);
        totalDuration = Math.max(60*60*24*6, end_timestamp - startTimestamp);

        // Force and set session repeater, as we want to have variables set beforehand
        repeaterSessions.model = currentDataModel;

        var days = Math.ceil(totalDuration / (3600 * 24));
        repeaterDays.model = days;
        repeaterDates.startDateTime = startDateTime;
    }

    ListModel{
        id: modelFiltered
    }

    Rectangle{
        anchors.fill: parent
        color: "black"

        Text{
            id: lblTitle
            anchors.left: parent.left
            anchors.right: cmbWeeks.left
            anchors.top: parent.top
            anchors.margins: 15
            text: title
            font.pixelSize: Constants.largeFontSize
            color: Constants.highlightColor
        }

        ComboBox{
            id: cmbWeeks
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 10
            textRole: "label"
            valueRole: "value"
            editable: false
            implicitContentWidthPolicy: ComboBox.WidestText
            model: [{label: "", value: ""}]

            onCurrentValueChanged: {
                updateTimeline();
            }

        }

        Rectangle{
            id: recBase
            anchors.top: cmbWeeks.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            //anchors.verticalCenter: parent.verticalCenter
            height: parent.height / 3
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
                }
            }

            Repeater{
                id: repeaterDays
                model: []

                Rectangle{
                    required property int index
                    property int overshoot: repeaterDates.model <= 10 || index === 0 ? 20 : 0
                    color: "white"
                    width: 1
                    x: ( index / repeaterDays.model) * recBase.width
                    height: recBase.height + overshoot

                }
            }

            Label{
                id: lblNoData
                visible: repeaterSessions.count === 0
                anchors.centerIn: parent
                text: qsTr("No data for that period")
            }
        }

        Repeater{
            id: repeaterDates
            model: repeaterDays.model
            property date startDateTime: new Date()

            Label{
                required property int index
                x: Math.min(recBase.width + recBase.x - implicitWidth, ( index / repeaterDates.model) * recBase.width + recBase.x + 5)
                y: recBase.height + recBase.y
                visible: repeaterDates.model > 0 && (repeaterDates.model <= 10 || index === 0 || index === repeaterDates.model-1)
                text: visible ? formatDate(addDays(repeaterDates.startDateTime, index)) : ""
            }
        }
    }
}
