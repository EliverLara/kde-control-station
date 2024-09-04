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
    Layout.fillHeight: true
    Layout.fillWidth: true
   // Layout.preferredHeight: root.sectionHeight/2
    
    // Get brightness control from KDE components
    ScreenBrightnessControl {
        id: sbControl
        isSilent: false
    }

    // Other properties
    property int screenBrightness: sbControl.brightness
    property bool disableBrightnessUpdate: true

    property bool isBrightnessAvailable: sbControl.isBrightnessAvailable
    readonly property int maximumScreenBrightness: sbControl.brightnessMax
    readonly property int brightnessMin: (maximumScreenBrightness > 100 ? 1 : 0)

    // Should be visible ONLY if the monitor supports it
    visible: isBrightnessAvailable && root.showBrightness

    // Slider properties
    title: "Display Brightness"
    source: "brightness-high"
    secondaryTitle: Math.round((screenBrightness / maximumScreenBrightness)*100) + "%"
    
    from: 0
    to: maximumScreenBrightness
    value: screenBrightness
    
    onMoved: {
        screenBrightness = value
        sbControl.brightness =  Math.max(brightnessMin, Math.min(maximumScreenBrightness, value));
    }

    Binding {
        id: binder
        target: brightnessControl
        property: "screenBrightness"
        value: sbControl.brightness
    }
    Binding {
        target: brightnessControl
        property: "isBrightnessAvailable"
        value: sbControl.isBrightnessAvailable
    }
}
