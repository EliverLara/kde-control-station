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

    property alias battery: mainBatteryWidget.battery
    
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

    // System session actions page
    Pages.SystemSessionActionsPage {
        id: systemSessionActionsPage
    }

    // Night Light Page
    Pages.NightLightPage {
        id: nightLightPage
    }

    // Volume devices Page
    Pages.VolumePage {
        id: volumePage
    }

    // Battery devices Page
    Pages.BatteryPage {
        id: batteryPage
    }

    // Media player Page
    Pages.MediaPlayerPage {
        id: mediaPlayerPage
    }

    // Brightness control Page
    Pages.BrightnessControlPage {
        id: brightnessControlPage
    }

    // Main wrapper
    ColumnLayout {
        id: wrapper

        anchors.fill: parent
        anchors.margins: 1
        spacing: 1

        RowLayout {
            id: header
            spacing: 1
            Layout.fillWidth: true
            anchors.margins: 1

            Components.UserAvatar{}
            Components.Battery {
                id: mainBatteryWidget
            }
            Components.SystemActions{}
        }

        RowLayout {
            id: sectionA

            spacing: 1
            anchors.margins: 1

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
