import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Effects
import QtQuick.Layouts

import DashboardsViewer 1.0

Item {
    implicitHeight: recBackground.height
    implicitWidth: recBackground.width

    id: baseItem

    property string title: ""
    property bool   showCloseButton: true

    default property alias  contentItem: mainItem.data
    property int            contentItemHeight: mainItem.implicitHeight
    property alias          headerBar: headerBar

    signal rejected()
    signal accepted()

    onAccepted: {
        //visible = false;
        fadeOut.start();
    }

    onRejected: {
        fadeOut.start();
    }

    anchors.fill: parent
    Keys.onReleased: (event) =>{
        if (event.key === Qt.Key_Back) {
            event.accepted = true;
        }
    }

    onVisibleChanged:{
        if (visible){
            fadeIn.start();
        }
    }
    Component.onCompleted: {
        fadeIn.start();
    }

     PropertyAnimation {
         id: fadeIn
         target: baseItem
         properties: "opacity"
         from: 0
         to: 1
         duration: 250
     }
     PropertyAnimation {
         id: fadeOut
         target: baseItem
         properties: "opacity"
         from: 1
         to: 0
         duration: 250
         onStopped: {
             visible = false;
         }
     }

    Rectangle{
        id: recBackground
        anchors.fill: parent
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Constants.lightBackgroundColor
            }
            GradientStop {
                position: 0.5
                color: Constants.highlightColor
            }
            GradientStop {
                position: 1.0
                color: Constants.lightBackgroundColor
            }
        }
        width: 400
        height: headerBar.height + mainItem.implicitHeight
        visible: true
        border.color: "grey"
        border.width: 2
        radius: 10
        Rectangle{
            id: headerBar
            anchors.left: parent.left
            anchors.right: parent.right
            height: 40
            color: "#7da4cf"

            ColumnLayout{
                anchors.fill: parent
                Text{
                    id: txtTitle
                    text: title
                    horizontalAlignment: Text.AlignHCenter
                    style: Text.Outline
                    Layout.fillWidth: true
                    font.bold: true
                    color: Constants.textColor
                    font.pixelSize: Constants.largeFontSize
                }
            }

        }

        Item{
            id: mainItem
            anchors.top: headerBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            //anchors.bottom: parent.bottom
            implicitHeight: childrenRect.height
            clip: true
        }
    }

    MultiEffect{
        source: recBackground
        anchors.fill: source
        visible: true
        shadowEnabled: true
        autoPaddingEnabled: true
        shadowScale: 1.01
    }
}
