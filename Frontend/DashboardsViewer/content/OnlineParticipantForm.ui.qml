

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 2.15
import QtQuick.Controls 2.15

Item {

    property alias id_participant: id_participant.text
    property alias id_participant_group: id_participant_group.text
    property alias participant_name: participant_name.text

    width: 300
    height: 300

    Column {
        id: column
        anchors.fill: parent
        spacing: 10

        Rectangle {
            id: background
            color: "#2da1d3"
            width: parent.width
            height: parent.height

            /*
            qml: OnlineParticipants  0  [id_participant] : 1
            qml: OnlineParticipants  0  [id_participant_group] : null
            qml: OnlineParticipants  0  [id_project] : 1
            qml: OnlineParticipants  0  [participant_busy] : false
            qml: OnlineParticipants  0  [participant_email] :
            qml: OnlineParticipants  0  [participant_enabled] : true
            qml: OnlineParticipants  0  [participant_name] : TestUser
            qml: OnlineParticipants  0  [participant_online] : true
            qml: OnlineParticipants  0  [participant_token_enabled] : true
            qml: OnlineParticipants  0  [participant_uuid] : dd75a936-7cc0-4ca5-af30-32fbe28bc760
            */
            Column {
                spacing: 10

                Row {
                    spacing: 10
                    Label {
                        text: qsTr("participant_name:")
                    }

                    Label {
                        id: participant_name
                        text: "Undefined"
                    }
                }

                Row {
                    spacing: 10
                    Label {
                        text: qsTr("id_participant:")
                    }

                    Label {
                        id: id_participant
                        text: "Undefined"
                    }
                }

                Row {
                    spacing: 10
                    Label {
                        text: qsTr("id_participant_group:")
                    }

                    Label {
                        id: id_participant_group
                        text: "Undefined"
                    }
                }
            }
        }
    }
}
