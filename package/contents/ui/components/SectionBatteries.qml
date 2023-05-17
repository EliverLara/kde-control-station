import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import "../lib" as Lib

ToggledSection {
    id: sectionBatteries

    text: i18n("Batteries")

    property int remainingTime

    delegate: Lib.BatteryItem {
        width: parent.width
        height: root.buttonHeight + 30
        battery: model
        remainingTime: sectionBatteries.remainingTime
    }
}
