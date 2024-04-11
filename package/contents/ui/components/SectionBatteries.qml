import QtQuick 2.15
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.15
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.networkmanagement as PlasmaNM
import "../lib" as Lib

ToggledSection {
    id: sectionBatteries

    sectionTitle: i18n("Batteries")

    property int remainingTime

    delegate: Lib.BatteryItem {
        width: parent.width
        height: root.buttonHeight + 30
        battery: model
        remainingTime: sectionBatteries.remainingTime
    }
}
