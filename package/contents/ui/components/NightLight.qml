import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.0

import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami 

import "../lib" as Lib

import org.kde.plasma.private.brightnesscontrolplugin


Lib.CardButton {
    id: nightLight

    Layout.fillHeight: true
    Layout.fillWidth: true

    visible: root.showNightLight
    title: i18n("Night Light")

    NightLightControl {
        id: control

        readonly property bool transitioning: control.currentTemperature != control.targetTemperature
        readonly property bool hasSwitchingTimes: control.mode != 3
        readonly property bool togglable: !control.inhibited || control.inhibitedFromApplet
    }

    property string command: root.preferChangeGlobalTheme ? 
                            "plasma-apply-lookandfeel -a " : 
                            "plasma-apply-colorscheme "
    Kirigami.Icon {
        anchors.fill: parent
        source: {
            if (!control.enabled) {
                return "redshift-status-on"; // not configured: show generic night light icon rather "manually turned off" icon
            } else if (!control.running) {
                return "redshift-status-off";
            } else if (control.daylight && control.targetTemperature != 6500) { // show daylight icon only when temperature during the day is actually modified
                return "redshift-status-day";
            } else {
                return "redshift-status-on";
            }
        }
    }

    onClicked: {
        nightLightPage.toggleSection()
    }
}
