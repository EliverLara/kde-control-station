import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami

import "../lib" as Lib
import "../js/funcs.js" as Funcs

Lib.CardButton {
    id: toggleButton
    Layout.fillWidth: true
    Layout.fillHeight: true
    property string icon
    property string commandOn: ""
    property string commandOff: ""
    property string commandStatus: ""
    property bool isActivated: false
    shouldStickIconSize: true

    property color normalBgColor: root.enableTransparency ? Qt.rgba(root.themeBgColor.r, root.themeBgColor.g, root.themeBgColor.b, root.transparencyLevel / 100) : root.themeBgColor

    property color activatedBgColor: Kirigami.Theme.highlightColor

    // Set background color based on activation state
    customBgColor: isActivated ? activatedBgColor : normalBgColor

    function execCommand(cmd) {
        commandExecutable.connectSource(cmd);
    }

    function checkStatus() {
        if (commandStatus !== "") {
            statusExecutable.connectSource(commandStatus);
        }
    }

    Component.onCompleted: {
        checkStatus();
        statusCheckTimer.start();
    }

    Kirigami.Icon {
        anchors.fill: parent
        source: icon
    }

    Timer {
        id: feedbackTimer
        interval: 300
        onTriggered: {
            // Update background after brief feedback
            toggleButton.customBgColor = isActivated ? activatedBgColor : normalBgColor;
        }
    }

    Timer {
        id: statusCheckTimer
        interval: 1000 // 1 second
        repeat: true
        running: false
        onTriggered: {
            checkStatus();
        }
    }

    // DataSource for executing commands (on/off)
    Plasma5Support.DataSource {
        id: commandExecutable
        engine: "executable"
        connectedSources: []

        onNewData: {
            disconnectSource(connectedSources);
            if (data["exit code"] == 0) {
                // Command succeeded - check status after execution
                feedbackTimer.restart();
                checkStatus();
            } else {
                // Command failed - show error briefly
                toggleButton.customBgColor = Kirigami.Theme.negativeTextColor;
                feedbackTimer.restart();
            }
        }
    }

    // DataSource for checking status
    Plasma5Support.DataSource {
        id: statusExecutable
        engine: "executable"
        connectedSources: []

        onNewData: {
            disconnectSource(connectedSources);
            var output = data["stdout"].trim().toLowerCase();

            // Check if output is "true" or exit code is 0
            if (output === "true" || output === "1") {
                isActivated = true;
            } else {
                isActivated = false;
            }
        }
    }

    onClicked: {
        // Execute the appropriate command based on current state
        if (isActivated) {
            execCommand(commandOff);
        } else {
            execCommand(commandOn);
        }
    }
}
