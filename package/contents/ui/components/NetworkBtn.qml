import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.core as PlasmaCore

import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.networkmanager as NMQt
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

    readonly property bool wifiCheckChecked: administrativelyEnabled && network.enabledConnections.wirelessEnabled
    readonly property bool wifiCheckVisible: network.availableDevices.wirelessDeviceAvailable

    readonly property bool airplaneCheckchecked: PlasmaNM.Configuration.airplaneModeEnabled
    readonly property bool airplaneCheckVisible: network.availableDevices.modemDeviceAvailable || network.availableDevices.wirelessDeviceAvailable

    readonly property var isWifi: wifiCheckChecked && wifiCheckVisible
    readonly property var isAirplane: airplaneCheckchecked && airplaneCheckVisible
    
    readonly property bool isConnected: {
        const c = network.networkStatus.connectivity;
        return c === NMQt.NetworkManager.Full || c === NMQt.NetworkManager.Limited || c === NMQt.NetworkManager.Portal;
    }

    Network {
        id: network
    }

    visible: true

    Layout.fillWidth: true
    Layout.fillHeight: true
    heading: isLongButton ? (isWifi ? i18n("Wi-Fi") : isAirplane ? i18n("Airplane mode") : i18n("Network")) : ""
    
    title: Funcs.getNetworkConnectionName()

    showContentOverflowIndicator: isLongButton

    Lib.Icon {
        anchors.fill: parent
        source: network.activeConnectionIcon
        selected: isWifi || isAirplane || isConnected
        enableQuickAction: root.enableQuickActions

        onQuickActionTriggered: {
            if(!wifiCheckVisible) { return; }
            if(!isAirplane) {
                network.handler.enableWireless(!wifiCheckChecked); 
            } else {
                network.handler.enableAirplaneMode(false);
                PlasmaNM.Configuration.airplaneModeEnabled = false;
            }
        }
    }
    onClicked: fullRep.togglePage(fullRep.defaultInitialWidth, 400, networkPage);
    
}