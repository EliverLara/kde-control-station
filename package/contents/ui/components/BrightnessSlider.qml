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

    property var mainScreen
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
        Component.onCompleted: update()
        function onDataChanged() { update(); }
        function onModelReset() { update(); }
        function onRowsInserted() { update(); }
        function onRowsMoved() { update(); }
        function onRowsRemoved() { update(); }
    }

    visible: sbControl.isBrightnessAvailable && root.showBrightness
    
    Loader {
        id: sliderLoader
        active: !!brightnessControl.mainScreen && brightnessControl.mainScreen.maxBrightness > 0
        sourceComponent: sliderComponent 
        anchors.fill: parent
    }

    Component {
        id: sliderComponent
        Lib.Slider {
                        
            readonly property int brightnessMin: (mainScreen.maxBrightness > 100 ? 1 : 0)

            // Slider properties
            title: mainScreen.label
            source: "brightness-high-symbolic"
            secondaryTitle: Math.round((mainScreen.brightness / mainScreen.maxBrightness)*100) + "%"

            canTogglePage: brightnessControl.canTogglePage
            glassEffect: brightnessControl.glassEffect
            cornerRadius: brightnessControl.cornerRadius
            mediumSizeSlider: brightnessControl.mediumSizeSlider
            roundedWidget: brightnessControl.roundedWidget
            
            showTitle: root.brightness_widget_title
            thinSlider: root.brightness_widget_thin
            flat: root.brightness_widget_flat || brightnessControl.flat // bind to Lib.Card property
            
            from: brightnessMin
            to: mainScreen.maxBrightness
            value: mainScreen.brightness
            stepSize: mainScreen.maxBrightness / 100
            
            onMoved: function(newValue) {
                sbControl.setBrightness(mainScreen.displayName, newValue);
            }

            onClicked: {
                var pageHeight = brightnessControlPage.contentItemHeight + brightnessControlPage.headerHeight;
                fullRep.togglePage(fullRep.defaultInitialWidth, pageHeight, brightnessControlPage);
            }
        }
    }
}
