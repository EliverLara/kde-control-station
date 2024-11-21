import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15
//import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import "../lib" as Lib
import org.kde.kitemmodels as KItemModels

import org.kde.plasma.private.brightnesscontrolplugin

Lib.Slider {
    id: brightnessControl
    
    // Dimensions
    Layout.fillHeight: true
    Layout.fillWidth: true
   // Layout.preferredHeight: root.sectionHeight/2
    
    // Get brightness control from KDE components
    ScreenBrightnessControl {
        id: sbControl
        isSilent: false
    }

    Connections {
        id: displayModelConnections
        target: sbControl.displays
        property var screenBrightnessInfo: []

        function update() {
            const [labelRole, brightnessRole, maxBrightnessRole, displayNameRole] = ["label", "brightness", "maxBrightness", "displayName"].map(
                (roleName) => target.KItemModels.KRoleNames.role(roleName));

            screenBrightnessInfo = [...Array(target.rowCount()).keys()].map((i) => { // for each display index
                const modelIndex = target.index(i, 0);
                return {
                    displayName: target.data(modelIndex, displayNameRole),
                    label: target.data(modelIndex, labelRole),
                    brightness: target.data(modelIndex, brightnessRole),
                    maxBrightness: target.data(modelIndex, maxBrightnessRole),
                };
            });
            brightnessControl.mainScreen = screenBrightnessInfo[0];
        }
        function onDataChanged() { update(); }
        function onModelReset() { update(); }
        function onRowsInserted() { update(); }
        function onRowsMoved() { update(); }
        function onRowsRemoved() { update(); }
    }

    // Other properties
    property var mainScreen: displayModelConnections.screenBrightnessInfo[0]
    property bool disableBrightnessUpdate: true

    readonly property int brightnessMin: (mainScreen.maxBrightness > 100 ? 1 : 0)

    // Should be visible ONLY if the monitor supports it
    visible: sbControl.isBrightnessAvailable && root.showBrightness

    // Slider properties
    title: mainScreen.label
    source: "brightness-high"
    secondaryTitle: Math.round((mainScreen.brightness / mainScreen.maxBrightness)*100) + "%"
    
    from: 0
    to: mainScreen.maxBrightness
    value: mainScreen.brightness
    
    onMoved: {
        sbControl.setBrightness(mainScreen.displayName, Math.max(brightnessMin, Math.min(mainScreen.maxBrightness, value))) ;
    }

    onTogglePage: brightnessControlPage.toggleSection()

    Connections {
        target: sbControl
    }
}
