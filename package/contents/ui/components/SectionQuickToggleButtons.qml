import QtQml 2.0
import QtQuick 2.0
import QtQuick.Layouts 1.15

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.bluezqt 1.0 as BluezQt
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM


import "../lib" as Lib
import "../js/funcs.js" as Funcs

Lib.Card {
    id: sectionQuickToggleButtons
    Layout.fillWidth: true
    Layout.fillHeight: true
    isContainer: true
    // NETWORK
    property var network: network
    Network {
        id: network
    }
    
    // BLUETOOTH
    property QtObject btManager : BluezQt.Manager
    
    // All Buttons
    ColumnLayout {
        id: buttonsColumn
        anchors.fill: parent
        anchors.margins: 1
        spacing: 1

        RowLayout {
            anchors.margins: 1
            spacing: 1
            NetworkBtn{}
            BluetoothBtn{}
        }

        RowLayout {
            anchors.margins: 1
            spacing: 1
            DndButton{}
            KDEConnect{}
        }
    }
}
