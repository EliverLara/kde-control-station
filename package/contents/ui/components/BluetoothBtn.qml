import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.core as PlasmaCore

// import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.kirigami as Kirigami
import org.kde.bluezqt 1.0 as BluezQt



import "../lib" as Lib
import "../js/funcs.js" as Funcs


Lib.CardButton {

    // BLUETOOTH
    property QtObject btManager : BluezQt.Manager

    visible: true

    Layout.fillWidth: true
    Layout.fillHeight: true
    
    title: Funcs.getBtDevice() // i18n("Bluetooth")
    Lib.Icon {
        anchors.fill: parent
        source: "network-bluetooth"
        selected:  Funcs.getBtDevice() != "Disabled"
    }
    onClicked: {
        Funcs.toggleBluetooth()
    }
}