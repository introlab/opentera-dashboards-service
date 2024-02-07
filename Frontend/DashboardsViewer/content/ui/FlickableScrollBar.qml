import QtQuick
import QtQuick.Controls

ScrollBar {
    policy: parent.contentHeight > parent.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    contentItem: Rectangle{
            color: "#33ffffff"
            radius: 20
        }
}
