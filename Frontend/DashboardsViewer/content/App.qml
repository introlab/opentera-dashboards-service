// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick 6.2
import DashboardsViewer
import QtQuick.VirtualKeyboard 6.2
import QtQuick.Controls 6.2

Window {
    width: Constants.width
    height: Constants.height

    visible: true
    title: "DashboardsViewer"

    StackView {
        id: stackview
        initialItem: loginView
        anchors.fill: parent
    }

    Component {
        id: loginView
        LoginForm {
            id: loginForm
        }
    }

    InputPanel {
        id: inputPanel
        property bool showKeyboard :  active
        y: showKeyboard ? parent.height - height : parent.height
        Behavior on y {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
        anchors.leftMargin: parent.width/10
        anchors.rightMargin: parent.width/10
        anchors.left: parent.left
        anchors.right: parent.right
    }
}

