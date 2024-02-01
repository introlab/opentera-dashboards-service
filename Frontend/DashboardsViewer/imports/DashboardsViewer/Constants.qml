pragma Singleton
import QtQuick 6.2
//import QtQuick.Studio.Application

QtObject {
    readonly property int width: 1280
    readonly property int height: 720

    property string relativeFontDirectory: "fonts"

    /* Edit this comment to add your custom font */
    readonly property int baseFontSize: 18
    readonly property int largeFontSize: baseFontSize * 1.6
    /*readonly property font font: Qt.font({
                                             family: Qt.application.font.family,
                                             pixelSize: Qt.application.font.pixelSize
                                         })
    readonly property font largeFont: Qt.font({
                                                  family: Qt.application.font.family,
                                                  pixelSize: Qt.application.font.pixelSize * 1.6
                                              })*/

    readonly property color backgroundColor: "#1b263b"
    readonly property color lightBackgroundColor: "#415a77"
    readonly property color highlightColor: "#778da9"
    readonly property color textColor: "#e0e1dd"

    /*property StudioApplication application: StudioApplication {
        fontPath: Qt.resolvedUrl("../../content/" + relativeFontDirectory)
    }*/
}
