import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import QtQuick.Dialogs
import QtCore

import DashboardsViewer
import "../ui"
import "../widgets"
import "../dataSources"

BaseDelegate {
    id: myDelegate
    height: parent ? Math.max(80, mainLayout.implicitHeight + mainLayout.anchors.margins*2) : 0
    width: parent ? (ListView && ListView.view.interactive ? parent.width - 20 : parent.width) : 0

    property int daysWarningThreshold: 7
    property int daysErrorThreshold: 14

    property bool showDownloadAssets: true

    property bool isCurrentItem: ListView ? ListView.isCurrentItem : false

    states: [
        /*State{
          name: "good"
          PropertyChanges {
              target: recBase
              color: "darkgreen"
          }
        },

        State {
            name: "warning"
            PropertyChanges {
                target: recBase
                color: "#77fcba03"
            }
        },
        State {
            name: "error"
            PropertyChanges {
                target: recBase
                color: "#77000000"//"#77ff0000"
            }
        }*/
    ]

    Component.onCompleted: function() {
        // Look for last_session
        if (model.session_start_datetime) {
            var lastSession = new Date(model.session_start_datetime)
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

    function formatDateTime(datetime_to_format){
        var str_date = "";
        var day = datetime_to_format.getDate();
        var month = datetime_to_format.getMonth() + 1;
        var year = datetime_to_format.getFullYear();
        var hours = datetime_to_format.getHours();
        var minutes = datetime_to_format.getMinutes();

        /*if (day < 10){
            str_date = "0"
        }
        str_date += day.toString() + " " + Qt.locale().monthName(month) + " " + year.toString() + " ";*/
        str_date = year.toString() + "-";
        if (month < 10){
            str_date += "0";
        }
        str_date += month.toString() + "-";
        if (day < 10){
            str_date += "0"
        }
        str_date += day.toString() + " ";

        if (hours < 10)
            str_date += "0";

        str_date += hours.toString() + ":";
        if (minutes < 10)
            str_date += "0";

        str_date += minutes.toString();

        return str_date;
    }

    Rectangle {
        id: recBase
        anchors.fill: parent
        color: Constants.highlightColor
        opacity: 0.8
        border.color: isCurrentItem ? "lightgrey" : "black"
        border.width: isCurrentItem ? 5 : 1
        radius: 5
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onDoubleClicked: {
                //console.log("SessionDelegate clicked");
                if (stackView) {
                    stackView.push("../widgets/SessionViewerWidget.qml", {"session": model})
                }
            }
            onPressAndHold: {
                //console.log("SessionDelegate long pressed");

                if (stackView) {
                    stackView.push("../widgets/SessionViewerWidget.qml", {"session": model})
                }

            }
            onClicked: {
                onClicked: {
                    if (myDelegate.ListView)
                        myDelegate.ListView.view.currentIndex = index;
                    model.dataSource.itemSelected(model[model.dataSource.fieldIdName])
                }
            }
        }
    }

    RowLayout {
        id: mainLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 5

        Rectangle{
            id: recSession
            height: imgSession.height + 8
            width: imgSession.width + 8
            radius: 4
            //color: model.session_type_color ? "#99" + model.session_type_color.substring(1) : "transparent"
            color: "transparent"
            //opacity: 0.5
            Image{
                id: imgSession
                anchors.centerIn: parent
                source: "../images/icons/session.png"
                fillMode: Image.PreserveAspectFit
                height: 32
                sourceSize.height: height
                width: height
                sourceSize.width: height
                //opacity: model.session_status === 2 ? 1.0 : 0.3  // Session completed or not
            }
        }

        ColumnLayout{
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 5
            RowLayout{
                Layout.fillWidth: true
                Badge{
                    visible: model.session_status === 2
                    text: qsTr("Completed")
                    color: "darkgreen"
                    padding: 0
                }
                Badge{
                    visible: model.session_status === 3
                    text: qsTr("Cancelled")
                    color: "darkred"
                    padding: 0
                }
                Badge{
                    visible: model.session_status === 4
                    text: qsTr("Terminated")
                    color: "red"
                    padding: 0
                }
                Badge{
                    visible: model.session_status === 1
                    text: qsTr("In progress")
                    color: "darkgrey"
                    padding: 0
                }
                Badge{
                    visible: model.session_status === 0
                    text: qsTr("Planned")
                    color: "white"
                    padding: 0
                    textColor: "black"
                }
                Badge{
                    visible: model.session_type_name
                    text: model.session_type_name
                    color: model.session_type_color ? model.session_type_color : "white"
                    padding: 0
                    textColor: "black"
                }
                Item{
                    Layout.fillWidth: true
                }
            }

            Text{
                id: txtName
                Layout.fillWidth: true
                text: model.session_name
                font.pixelSize: Constants.baseFontSize
                wrapMode: Text.WordWrap
                style: Text.Outline
                color: Constants.textColor
            }

            Text{
                id: txtDate
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                property date sessionDate: new Date(model.session_start_datetime)
                text: sessionDate.toLocaleDateString() +" - " + sessionDate.toLocaleTimeString()
                font.pixelSize: Constants.baseFontSize
                style: Text.Outline
                font.bold: true
                color: Constants.textAltColor
                wrapMode: Text.WordWrap
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

        }
        ImageButtonWidget{
            id: btnDownload
            visible: model.session_assets_count > 0 && showDownloadAssets
            imgPath: "../images/icons/data.png"
            onClicked: {
                if (dashboardViewerApp.isWebAssembly()) {
                    //This will use the browser download function. Download UI is provided by browser.
                    fileDownloader.filename = model[model.dataSource.fieldDisplayName]

                    //DownloadFile returnes a null object in WebASM
                    fileDownloader.downloadParticipantArchive(model[model.dataSource.fieldIdName])
                } else {
                    //console.log('WebAssembly is not supported');
                    saveFileDialog.open();
                }

            }
        }
    }

    FileDownloadDataSource{
        id: fileDownloader
        onCompressingChanged:{
            if (screenLoading !== undefined){
                screenLoading.text = qsTr("Compressing data...");
                screenLoading.visible = compressing;
                screenLoading.progressValue = -1;
            }
        }
        onDownloadingChanged: {
            if (screenLoading !== undefined){
                screenLoading.text = qsTr("Downloading...");
                screenLoading.visible = downloading;
                screenLoading.progressValue = 0;
            }
        }
        onDownloadProgress: function(bytesReceived, bytesTotal){
            if (screenLoading !== undefined){
                screenLoading.progressValue = (bytesReceived / bytesTotal) * 100
            }
        }
    }
    FileDialog {
        id: saveFileDialog
        nameFilters: ["Zip files (*.zip)"]
        defaultSuffix: ".zip"
        fileMode: FileDialog.SaveFile
        //URL
        currentFolder: StandardPaths.writableLocation(StandardPaths.DownloadLocation)
        selectedFile: currentFolder + "/" + model[model.dataSource.fieldDisplayName] + ".zip"
        onAccepted: function() {
            fileDownloader.filename = saveFileDialog.currentFile;
            fileDownloader.downloadSessionArchive(model[model.dataSource.fieldIdName])
        }
     }
} // Item
