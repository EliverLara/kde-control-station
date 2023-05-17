import QtQuick 2.0
import QtQuick.Layouts 1.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents2
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
import org.kde.kcoreaddons 1.0 as KCoreAddons
import org.kde.plasma.workspace.components 2.0

import "../lib" as Lib

Lib.Card { 
    id: battery

    Layout.fillWidth: true
    Layout.preferredHeight: root.sectionHeight/3.5

    property var battery

    RowLayout {
        anchors.fill: parent
        anchors.margins: root.mediumSpacing
        
        clip: true
        
        BatteryIcon {
            id: batteryIcon

            Layout.alignment: Qt.AlignCenterLeft
            Layout.preferredWidth: PlasmaCore.Units.iconSizes.medium
            Layout.preferredHeight: PlasmaCore.Units.iconSizes.medium

            percent: battery.battery.Percent
            hasBattery: battery.battery["Has Battery"]
            pluggedIn: battery.battery.State === "Charging"

        }

        PlasmaComponents.Label {
            id: percentLabel
            horizontalAlignment: Text.AlignLeft
            text: i18nc("Placeholder is battery percentage", "%1%", battery.battery.Percent)
        }
    }
}