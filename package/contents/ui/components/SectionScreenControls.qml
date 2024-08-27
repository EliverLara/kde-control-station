import QtQml 2.0
import QtQuick 2.0
import QtQuick.Layouts 1.15

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami as Kirigami

import "../lib" as Lib
import "../js/funcs.js" as Funcs

Lib.Card {
    id: sectionScreenControls
    Layout.fillWidth: true
    Layout.preferredHeight: (brightnessSlider.visible && secondaryRow.visible) ?  root.sectionHeight : root.sectionHeight/2
    Layout.alignment: Qt.AlignTop
    visible: brightnessSlider.visible || root.showBrightness || root.showColorSwitcher || root.showNightLight
    // All Buttons
    ColumnLayout {
        id: buttonsColumn
        anchors.fill: parent
        anchors.margins: root.smallSpacing
        spacing: root.smallSpacing

        BrightnessSlider{
            id: brightnessSlider
        }

        RowLayout {
            id: secondaryRow
            visible: root.showColorSwitcher || root.showNightLight
            NightLight{}
            ColorSchemeSwitcher{}
        }
    }
}
