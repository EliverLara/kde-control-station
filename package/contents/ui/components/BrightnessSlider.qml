import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15
//import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import "../lib" as Lib

import org.kde.plasma.private.brightnesscontrolplugin

Lib.Slider {
    id: brightnessControl
    // Dimensions
    Layout.fillWidth: true
    Layout.preferredHeight: root.sectionHeight/2
    
    // Should be visible ONLY if the monitor supports it
    visible: isBrightnessAvailable && root.showBrightness

    // Get brightness control from KDE components
    ScreenBrightnessControl {
        id: sbControl
        isSilent: true
    }
    
    // Slider properties
    title: "Display Brightness"
    source: "brightness-high"
    secondaryTitle: Math.round((screenBrightness / maximumScreenBrightness)*100) + "%"
    
    from: 0
    to: maximumScreenBrightness
    value: screenBrightness
    
    // Other properties
    property alias screenBrightness: sbControl.brightness
    property bool disableBrightnessUpdate: true

    readonly property bool isBrightnessAvailable: sbControl.isBrightnessAvailable
    readonly property int maximumScreenBrightness: sbControl.brightnessMax
    readonly property int brightnessMin: (maximumScreenBrightness > 100 ? 1 : 0)

    
    onMoved: {
        screenBrightness = value
        sbControl.brightness =  Math.max(brightnessMin, Math.min(maximumScreenBrightness, value));
    }
}
