import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.private.volume as Vol

import "../lib" as Lib
import "../js/funcs.js" as Funcs

Item {
    id: volumeControl
    Layout.fillWidth: true
    Layout.fillHeight: true
    visible: sinkAvailable && root.showVolume

    property bool canTogglePage: true

    property bool glassEffect: false
    property int cornerRadius: roundedWidget ? 22 : 12
    property bool mediumSizeSlider: false

    property bool isLongButton: true
    property bool roundedWidget: false

    /* 
    * When using Custom layout we control these properties by changes
    * in context menu, otherwise it's controlled by sliders config in
    * plasmoid settings window-
    */

    property bool showTitle: plasmoid.configuration.layout == root.layouts.Custom ? true : root.volume_widget_title
    property bool flat: plasmoid.configuration.layout == root.layouts.Custom ? false : root.volume_widget_flat

    // Audio source
    property var sink: Vol.PreferredDevice.sink
    readonly property bool sinkAvailable: sink && !(sink && sink.name == "auto_null")

    Loader {
        id: sliderLoader
        active: volumeControl.sinkAvailable
        sourceComponent: sliderComponent 
        anchors.fill: parent
    }

    Component {
        id: sliderComponent
        Lib.Slider {
            id: slider
            useIconButton: true
            title: i18n("Volume")
            canTogglePage: volumeControl.canTogglePage
            glassEffect: volumeControl.glassEffect
            cornerRadius: volumeControl.cornerRadius
            mediumSizeSlider: volumeControl.mediumSizeSlider
            roundedWidget: volumeControl.roundedWidget
            showTitle: volumeControl.showTitle
            thinSlider: root.volume_widget_thin
            flat: volumeControl.flat// bind to Lib.Card property

            value: Math.round(sink.volume / Vol.PulseAudio.NormalVolume * 100)
            secondaryTitle: Math.round(sink.volume / Vol.PulseAudio.NormalVolume * 100) + "%"

            // Changes icon based on the current volume percentage
            source: Funcs.volIconName(sink.volume, sink.muted)

            onPressedChanged: {
                if (!pressed) {
                    // Make sure to sync the volume once the button was
                    // released.
                    // Otherwise it might be that the slider is at v10
                    // whereas PA rejected the volume change and is
                    // still at v15 (e.g.).
                    volumePage.playFeedback(sink.Index);
                }
            }
            
            onMoved: function(newValue) {
                sink.volume = newValue * Vol.PulseAudio.NormalVolume / 100;
            }
            
            // Display view that shows audio devices list
            onClicked: {
                var pageHeight =  volumePage.contentItemHeight + volumePage.headerHeight;
                fullRep.togglePage(fullRep.defaultInitialWidth, pageHeight, volumePage);
            }
            
            property var oldVol: 100 * Vol.PulseAudio.NormalVolume / 100
            onActionButtonClicked: {
                if(value!=0){
                    oldVol = sink.volume
                    sink.volume=0
                } else {
                    sink.volume=oldVol
                }
            }
        }
    }
}