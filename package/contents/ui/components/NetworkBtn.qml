import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.core as PlasmaCore

import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.kirigami as Kirigami



import "../lib" as Lib
import "../js/funcs.js" as Funcs


Lib.CardButton {

    // NETWORK
    property var network: network

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
    
    title: network.networkStatus.activeConnections ?  "Connected" : isAirplane ? "On" : "Disconnected" //(isWifi || isWired) ? "Connected" : isAirplane ? "On" : "Disconnected"
    Lib.Icon {
        anchors.fill: parent
        source: network.activeConnectionIcon
        selected: (network.networkStatus.activeConnections != "") || isAirplane 
    }
    onClicked: {
        sectionNetworks.toggleNetworkSection();
    }
}