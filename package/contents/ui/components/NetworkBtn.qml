import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.kirigami as Kirigami

import "../lib" as Lib

Lib.Card {

    id: networkBtn
    property bool isLongButton: false
    clip: true

    // Device availability checks
    readonly property bool hasWirelessDevice: network.availableDevices.wirelessDeviceAvailable
    readonly property bool hasModemDevice: network.availableDevices.modemDeviceAvailable
    readonly property bool isAirplaneModeOn: PlasmaNM.Configuration.airplaneModeEnabled

    // Administrative enablement checks
    readonly property bool administrativelyEnabled: !isAirplaneModeOn && hasWirelessDevice && network.enabledConnections.wirelessHwEnabled
    readonly property bool administrativelyWiredEnabled: !isAirplaneModeOn && hasModemDevice && network.enabledConnections.wwanHwEnabled

    // Connection state checks
    readonly property bool wifiCheckChecked: administrativelyEnabled && network.enabledConnections.wirelessEnabled
    readonly property bool wifiCheckVisible: hasWirelessDevice

    readonly property bool airplaneCheckChecked: isAirplaneModeOn
    readonly property bool airplaneCheckVisible: hasModemDevice || hasWirelessDevice

    readonly property bool wiredCheckChecked: administrativelyWiredEnabled && network.enabledConnections.wwanEnabled
    readonly property bool wiredCheckVisible: hasModemDevice

    // Computed state for active connection types
    readonly property bool isWifi: wifiCheckChecked && wifiCheckVisible
    readonly property bool isAirplane: airplaneCheckChecked && airplaneCheckVisible
    readonly property bool isWired: wiredCheckChecked && wiredCheckVisible

    // Helper functions and computed properties
    function getConnectionStatusText() {
        if (network.networkStatus.activeConnections) {
            return i18n("Connected")
        } else if (isAirplane) {
            return i18n("On")
        } else {
            return i18n("Disconnected")
        }
    }

    function getConnectionTypeText() {
        if (isWifi) return i18n("Wi-Fi")
        if (isAirplane) return i18n("Airplane mode")
        return i18n("Network")
    }

    // Layout size helpers
    readonly property bool isSmallLayout: width < root.fullRepWidth/3
    readonly property bool shouldShowExtendedUI: !isSmallLayout

    // Font size helpers
    readonly property int primaryFontSize: isSmallLayout ? root.smallFontSize + 0.5 : root.mediumFontSize
    readonly property int secondaryFontSize: shouldShowExtendedUI ? root.smallFontSize + 0.5 : root.mediumFontSize

    Network {
        id: network
    }

    Layout.fillWidth: true
    Layout.fillHeight: true

    // Unified background for long button
    Rectangle {
        id: unifiedBackground
        anchors.fill: parent
        color: Kirigami.Theme.highlightColor
        opacity: (isWifi || isAirplane || isWired) ? 0.5 : 0
        radius: networkBtn.cornerRadius
        visible: isLongButton

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }

        // Long button layout (unified button with divider)
        RowLayout {
            id: longLayout
            anchors.fill: parent
            spacing: isSmallLayout ? 0 : root.smallSpacing / 2
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: longLayout.width
                    height: longLayout.height
                    radius: networkBtn.cornerRadius
                }
            }

        // Left side (toggle)
        RowLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: isSmallLayout ? 0 : root.smallSpacing / 2

            Item {
                id: iconLong
                Layout.preferredHeight: isSmallLayout ? longLayout.height/2 : longLayout.height * 0.6
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
                    visible: shouldShowExtendedUI
                    text: getConnectionTypeText()
                    horizontalAlignment: Qt.AlignLeft
                    verticalAlignment: Qt.AlignBottom
                }

                PlasmaComponents.Label {
                    id: titleLong
                    width: parent.width
                    height: parent.height / 2
                    leftPadding: (isSmallLayout || !heading.visible) ? root.smallSpacing : 1
                    font.pixelSize: secondaryFontSize
                    font.weight: (isSmallLayout || !heading.visible) ? Font.Bold : Font.Normal
                    horizontalAlignment: isSmallLayout ? Qt.AlignHCenter : Qt.AlignLeft
                    verticalAlignment: !heading.visible ? Qt.AlignVCenter : Qt.AlignTop
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    text: getConnectionStatusText()
                }
            }

            MouseArea {
                id: toggleArea
                anchors.fill: parent
                hoverEnabled: false
                enabled: !root.editingLayout

                onClicked: {
                    // Toggle network on/off based on available device type
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
                }
            }
        }

        // Divider
        Rectangle {
            id: divider
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: Kirigami.Theme.textColor
            opacity: 0.3
            visible: shouldShowExtendedUI
        }

        // Right side (arrow/open settings) - just the icon
        Item {
            id: rightButtonArea
            Layout.preferredWidth: networkBtn.height * 0.3
            Layout.fillHeight: true
            visible: shouldShowExtendedUI

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

            // Hover background
            Rectangle {
                anchors.fill: parent
                color: Kirigami.Theme.highlightColor
                opacity: arrowArea.containsMouse ? 0.2 : 0
                radius: networkBtn.cornerRadius
                z: -1

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
            }
        }
        } // Close RowLayout
    } // Close Rectangle


    // Short button layout (icon with circle background on top, text below, opens submenu)
    GridLayout {
        id: shortLayout
        anchors.fill: parent
        anchors.margins: isSmallLayout ? root.smallSpacing : root.largeSpacing
        rows: 2
        columns: isSmallLayout ? 1 : 2
        columnSpacing: isSmallLayout ? 0 : 10*root.scale
        rowSpacing: 0
        visible: !isLongButton

        Item {
            id: iconShort
            Layout.preferredHeight: isSmallLayout ? shortLayout.height/1.5 : shortLayout.height - root.largeSpacing
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
            Layout.margins: isSmallLayout ? root.smallSpacing : 1
            Layout.rowSpan: 2
            font.pixelSize: primaryFontSize
            font.weight: Font.Bold
            horizontalAlignment: isSmallLayout ? Qt.AlignHCenter : Qt.AlignLeft
            verticalAlignment: Qt.AlignVCenter
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            visible: text
            text: getConnectionStatusText()
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        enabled: !root.editingLayout
        visible: !isLongButton

        onClicked: {
            // Short button: Open network page
            fullRep.togglePage(fullRep.defaultInitialWidth, 400, networkPage)
        }
    }
}