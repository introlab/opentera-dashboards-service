import QtQuick 2.15

BaseWidget {
    width: 200
    height: 200

    property string currentTime: ""

    Timer {
        interval: 1000 // Update every second
        running: true
        repeat: true
        onTriggered: {
            updateTime();
        }
    }

    function updateTime() {
        var now = new Date();
        var hours = now.getHours();
        var minutes = now.getMinutes();
        var seconds = now.getSeconds();

        // Format the time with leading zeros
        currentTime = padZero(hours) + ":" + padZero(minutes) + ":" + padZero(seconds);
    }

    function padZero(value) {
        return value < 10 ? "0" + value : value;
    }

    Text {
        anchors.centerIn: parent
        text: currentTime
        font.pixelSize: 24
    }
}
