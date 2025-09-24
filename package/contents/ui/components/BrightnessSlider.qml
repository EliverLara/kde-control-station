import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15
//import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import "../lib" as Lib
import org.kde.kitemmodels as KItemModels

import org.kde.plasma.private.brightnesscontrolplugin

Item {
    id: brightnessControl

    Layout.fillHeight: true
    Layout.fillWidth: true

    property var screenBrightnessInfo: []
    property bool disableBrightnessUpdate: true

    property bool canTogglePage: false

    property bool glassEffect: false
    property int cornerRadius: roundedWidget ? 22 : 12
    property bool mediumSizeSlider: false

    property bool flat: false
    property bool isLongButton: false
    property bool roundedWidget: false
    property bool showTitle: false

    ScreenBrightnessControl {
        id: sbControl
        isSilent: false
    }

    Connections {
        id: displayModelConnections
        target: sbControl.displays

        function update() {
            const [labelRole, brightnessRole, maxBrightnessRole, displayNameRole] = ["label", "brightness", "maxBrightness", "displayName"].map(
                (roleName) => target.KItemModels.KRoleNames.role(roleName));

            brightnessControl.screenBrightnessInfo = [...Array(target.rowCount()).keys()].map((i) => { // for each display index
                const modelIndex = target.index(i, 0);
                return {
                    displayName: target.data(modelIndex, displayNameRole),
                    label: target.data(modelIndex, labelRole),
                    brightness: target.data(modelIndex, brightnessRole),
                    maxBrightness: target.data(modelIndex, maxBrightnessRole),
                };
            });
            sliderLoader.active = true;
        }
        function onDataChanged() { update(); }
        function onModelReset() { update(); }
        function onRowsInserted() { update(); }
        function onRowsMoved() { update(); }
        function onRowsRemoved() { update(); }
    }

    visible: sbControl.isBrightnessAvailable && root.showBrightness
    
    Loader {
        id: sliderLoader
        active: false
        sourceComponent: sliderComponent 
        anchors.fill: parent
    }

    Component {
        id: sliderComponent
        Lib.Slider {
            // Slider properties
            title: "Brightness"
            source: "brightness-high"
            secondaryTitle: Math.round(value) + "%"

            canTogglePage: brightnessControl.canTogglePage
            glassEffect: brightnessControl.glassEffect
            cornerRadius: brightnessControl.cornerRadius
            mediumSizeSlider: brightnessControl.mediumSizeSlider
            roundedWidget: brightnessControl.roundedWidget
            
            showTitle: root.brightness_widget_title
            thinSlider: root.brightness_widget_thin
            flat: root.brightness_widget_flat || brightnessControl.flat // bind to Lib.Card property
            
            from: 0
            to: 100
            value: screenBrightnessInfo.map(screen => screen.brightness).reduce((a,b) => a + b, 0) / screenBrightnessInfo.length
            
            onMoved: {
                let perc = value / 100;
                screenBrightnessInfo.forEach((screen) => {
                  let minBrightness = Number(screen.maxBrightness > 100);
                  sbControl.setBrightness(screen.displayName, Math.max(minBrightness, perc * screen.maxBrightness));
                })
            }

            onTogglePage: {
                var pageHeight = brightnessControlPage.contentItemHeight + brightnessControlPage.headerHeight;
                fullRep.togglePage(fullRep.defaultInitialWidth, pageHeight, brightnessControlPage);
            }
        }
    }
}
