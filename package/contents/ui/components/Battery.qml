import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents2
import org.kde.plasma.components as PlasmaComponents
import org.kde.kquickcontrolsaddons as KQuickAddons
import org.kde.coreaddons as KCoreAddons
import org.kde.plasma.workspace.components 2.0
import org.kde.kirigami as Kirigami

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

            Layout.alignment: Qt.AlignCenterLeft | Qt.AlignVcenter
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium

            percent: battery.battery.Percent
            hasBattery: battery.battery["Has Battery"]
            pluggedIn: battery.battery.State === "Charging"

        }

        PlasmaComponents.Label {
            id: percentLabel
            horizontalAlignment: Text.AlignLeft
            text: i18nc("Placeholder is battery percentage", "%1%", battery.battery.Percent)
            font.pixelSize: root.mediumFontSize
            font.weight:Font.Bold
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: false
        onClicked: {
            sectionBatteries.toggleSection()
        }
    }
}
