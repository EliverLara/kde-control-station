import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.kirigami as Kirigami

import "../lib" as Lib

Lib.Card {

    id: networkBtn
    property bool isLongButton: false
    clip: true

    readonly property bool administrativelyEnabled:
                !PlasmaNM.Configuration.airplaneModeEnabled
                && network.availableDevices.wirelessDeviceAvailable
                && network.enabledConnections.wirelessHwEnabled

    readonly property bool administrativelyWiredEnabled:
                !PlasmaNM.Configuration.airplaneModeEnabled
                && network.availableDevices.modemDeviceAvailable
                && network.enabledConnections.wwanHwEnabled

    readonly property bool wifiCheckChecked: administrativelyEnabled && network.enabledConnections.wirelessEnabled
    readonly property bool wifiCheckVisible: network.availableDevices.wirelessDeviceAvailable

    readonly property bool airplaneCheckchecked: PlasmaNM.Configuration.airplaneModeEnabled
    readonly property bool airplaneCheckVisible: network.availableDevices.modemDeviceAvailable || network.availableDevices.wirelessDeviceAvailable

    readonly property bool wiredCheckchecked: administrativelyWiredEnabled && network.enabledConnections.wwanEnabled
    readonly property bool wiredCheckVisible: network.availableDevices.modemDeviceAvailable

    readonly property var isWifi: wifiCheckChecked && wifiCheckVisible
    readonly property var isAirplane: airplaneCheckchecked && airplaneCheckVisible
    readonly property var isWired: wiredCheckchecked && wiredCheckVisible

    Network {
        id: network
    }

    visible: true

    Layout.fillWidth: true
    Layout.fillHeight: true

    // Long button layout (with toggle and arrow)
    RowLayout {
        id: longLayout
        anchors.fill: parent
        property bool small: width < root.fullRepWidth/3
        anchors.margins: small ? root.smallSpacing : root.mediumSpacing
        spacing: small ? 0 : root.smallSpacing
        visible: isLongButton

        Item {
            id: iconLong
            Layout.preferredHeight: longLayout.small ? longLayout.height/2 : longLayout.height * 0.6
            Layout.preferredWidth: Layout.preferredHeight
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft

            Kirigami.Icon {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                width: parent.width
                height: parent.height
                source: network.activeConnectionIcon
                color: Kirigami.Theme.textColor
            }
        }

        Column {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            PlasmaComponents.Label {
                id: heading
                width: parent.width
                height: parent.height / 2

                font.pixelSize: root.mediumFontSize
                font.weight: Font.Bold
                elide: Text.ElideRight
                visible: !longLayout.small
                text: isWifi ? i18n("Wi-Fi") : isAirplane ? i18n("Airplane mode") : i18n("Network")
                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignBottom
            }

            PlasmaComponents.Label {
                id: titleLong
                width: parent.width
                height: parent.height / 2
                leftPadding: (longLayout.small || !heading.visible) ? root.smallSpacing : 1
                font.pixelSize: (longLayout.small || heading.visible) ? root.smallFontSize+0.5 : root.mediumFontSize
                font.weight: (longLayout.small || !heading.visible) ? Font.Bold : Font.Normal
                horizontalAlignment: longLayout.small ? Qt.AlignHCenter : Qt.AlignLeft
                verticalAlignment: !heading.visible ? Qt.AlignVCenter : Qt.AlignTop
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                text: network.networkStatus.activeConnections ? i18n("Connected") : isAirplane ? i18n("On") : i18n("Disconnected")
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: Kirigami.Theme.textColor
            opacity: 0.2
            visible: !longLayout.small
        }

        Item {
            Layout.preferredWidth: networkBtn.height * 0.3
            Layout.fillHeight: true
            visible: !longLayout.small

            Rectangle {
                anchors.fill: parent
                color: Kirigami.Theme.highlightColor
                opacity: arrowArea.containsMouse ? 0.2 : 0
                radius: 4

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
            }

            Kirigami.Icon {
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height) * 0.4
                height: width
                source: "go-next"
                color: Kirigami.Theme.textColor
            }

            MouseArea {
                id: arrowArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: !root.editingLayout

                onClicked: {
                    fullRep.togglePage(fullRep.defaultInitialWidth, 400, networkPage)
                }
            }
        }
    }

    // Short button layout (icon with circle background on top, text below, opens submenu)
    GridLayout {
        id: shortLayout
        anchors.fill: parent
        property bool small: width < root.fullRepWidth/3
        anchors.margins: shortLayout.small ? root.smallSpacing : root.largeSpacing
        rows: 2
        columns: shortLayout.small ? 1 : 2
        columnSpacing: shortLayout.small ? 0 : 10*root.scale
        rowSpacing: 0
        visible: !isLongButton

        Item {
            id: iconShort
            Layout.preferredHeight: shortLayout.small ? shortLayout.height/1.5 : shortLayout.height - root.largeSpacing
            Layout.preferredWidth: Layout.preferredHeight
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.rowSpan: 2

            Lib.Icon {
                anchors.fill: parent
                source: network.activeConnectionIcon
                selected: (network.networkStatus.activeConnections != "") || isAirplane 
            }
        }

        PlasmaComponents.Label {
            id: titleShort
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: shortLayout.small ? root.smallSpacing : 1
            Layout.rowSpan: 2
            font.pixelSize: shortLayout.small ? root.smallFontSize+0.5 : root.mediumFontSize
            font.weight: Font.Bold
            horizontalAlignment: shortLayout.small ? Qt.AlignHCenter : Qt.AlignLeft
            verticalAlignment: Qt.AlignVCenter
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            visible: text
            text: network.networkStatus.activeConnections ? i18n("Connected") : isAirplane ? i18n("On") : i18n("Disconnected")
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Kirigami.Theme.highlightColor
        opacity: (isWifi || isAirplane || isWired) ? 0.5 : (toggleArea.containsMouse ? 0.15 : 0)
        radius: networkBtn.cornerRadius
        z: -1
        visible: isLongButton

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }

    MouseArea {
        id: toggleArea
        anchors.fill: parent
        anchors.rightMargin: (isLongButton && !longLayout.small) ? networkBtn.height * 0.3 + root.smallSpacing + 1 : 0
        hoverEnabled: true
        enabled: !root.editingLayout

        onClicked: {
            if (isLongButton) {
                // Long button: Toggle network on/off based on available device type
                if (wifiCheckVisible) {
                    // Toggle WiFi
                    network.handler.enableWireless(!network.enabledConnections.wirelessEnabled)
                } else if (airplaneCheckVisible) {
                    // Toggle airplane mode
                    PlasmaNM.Configuration.airplaneModeEnabled = !PlasmaNM.Configuration.airplaneModeEnabled
                } else if (wiredCheckVisible) {
                    // Toggle wired/WWAN
                    network.handler.enableWwan(!network.enabledConnections.wwanEnabled)
                }
            } else {
                // Short button: Open network page
                fullRep.togglePage(fullRep.defaultInitialWidth, 400, networkPage)
            }
        }
    }
}