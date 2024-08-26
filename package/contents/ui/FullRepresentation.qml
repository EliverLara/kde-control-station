import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.0

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents

import "lib" as Lib
import "components" as Components
import "pages" as Pages
import "js/funcs.js" as Funcs 


Item {
    id: fullRep

    property alias remainingTime: sectionBatteries.remainingTime
    property alias battery: mainBatteryWidget.battery
    property QtObject batteries
    
    // PROPERTIES
    Layout.preferredWidth: root.fullRepWidth
    Layout.preferredHeight: wrapper.implicitHeight
    Layout.minimumWidth: Layout.preferredWidth
    Layout.maximumWidth: Layout.preferredWidth
    Layout.minimumHeight: Layout.preferredHeight
    Layout.maximumHeight: Layout.preferredHeight
    clip: true
    
    // Lists all available network connections
    Components.SectionNetworks{
        id: sectionNetworks
    }

    // Lists all available batteries
    Components.SectionBatteries {
        id: sectionBatteries
        model: fullRep.batteries
        remainingTime: fullRep.remainingTime
    }

    // System session actions page
    Pages.SystemSessionActionsPage {
        id: systemSessionActionsPage
    }

    // Night Light Page
    Pages.NightLightPage {
        id: nightLightPage
    }

    // Main wrapper
    ColumnLayout {
        id: wrapper

        anchors.fill: parent
        spacing: root.itemSpacing

        RowLayout {
            id: header

            Layout.fillWidth: true

            Components.UserAvatar{}
            Components.Battery {
                id: mainBatteryWidget
            }
            Components.SystemActions{}
        }

        RowLayout {
            id: sectionA

            spacing: root.itemSpacing

            Layout.preferredHeight: root.sectionHeight
            Layout.maximumHeight: root.sectionHeight
            
            // Network, Bluetooth and Settings Button
            Components.SectionQuickToggleButtons{}

            // Screen controls section
            Components.SectionScreenControls{}
        }

        Components.Volume{}
        Components.MediaPlayer{}
    }
}
