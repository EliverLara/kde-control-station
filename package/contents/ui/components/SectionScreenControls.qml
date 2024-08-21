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
    Layout.fillHeight: true
    
    // All Buttons
    ColumnLayout {
        id: buttonsColumn
        anchors.fill: parent
        anchors.margins: root.smallSpacing
        spacing:  root.smallSpacing

        BrightnessSlider{}

        RowLayout {
            ColorSchemeSwitcher{}
        }
    }
}
