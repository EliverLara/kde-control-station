import QtQuick 2.15
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.15
//import QtGraphicalEffects 1.15

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

import org.kde.plasma.workspace.components
import org.kde.coreaddons as KCoreAddons
import org.kde.ksvg as KSvg

import org.kde.kirigami as Kirigami


KSvg.FrameSvgItem {
    id: batteryItem

    imagePath: "widgets/viewitem"
    prefix: mouseArea.containsMouse ? (mouseArea.pressed ? "selected+hover" : "hover") : "normal"
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.rightMargin: root.smallSpacing
    Layout.leftMargin: root.smallSpacing
    signal clicked;

    property int margin: root.buttonMargin

    property var battery

    readonly property bool isPresent: batteryItem.battery["Plugged in"]

    readonly property bool isPowerSupply: batteryItem.battery["Is Power Supply"]

    readonly property bool isBroken: root.battery.Capacity > 0 && root.battery.Capacity < 50

    property int remainingTime: 0

    RowLayout {
        anchors.fill: parent
       // anchors.margins: button.margin
        spacing: Kirigami.Units.gridUnit
        clip: true

        BatteryIcon {
            id: batteryIcon

            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium

            batteryType: batteryItem.battery.Type
            percent: batteryItem.battery.Percent
            hasBattery: batteryItem.isPresent
            pluggedIn: batteryItem.battery.State === "Charging" && batteryItem.battery["Is Power Supply"]
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: batteryItem.isPresent ? Qt.AlignTop : Qt.AlignVCenter
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: batteryItem.battery["Pretty Name"]
                }

                PlasmaComponents.Label {
                    id: isPowerSupplyLabel
                    text: stringForBatteryState(batteryItem.battery, pmSource)
                    // For non-power supply batteries only show label for known-good states
                    visible: batteryItem.isPowerSupply || ["Discharging", "FullyCharged", "Charging"].includes(batteryItem.battery.State)
                    enabled: false
                }

                PlasmaComponents.Label {
                    id: percentLabel
                    horizontalAlignment: Text.AlignRight
                    visible: batteryItem.isPresent
                    text: i18nc("Placeholder is battery percentage", "%1%", batteryItem.battery.Percent)
                }
            }

            PlasmaComponents.ProgressBar {
                id: chargeBar

                Layout.fillWidth: true
                from: 0
                to: 100
                visible: batteryItem.isPresent
                value: Number(batteryItem.battery.Percent)
            }


            // This gridLayout basically emulates an at-most-two-rows table with a
            // single wide fillWidth/columnSpan header. Not really worth it trying
            // to refactor it into some more clever fancy model-delegate stuff.
            GridLayout {
                id: details

                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.smallSpacing

                columns: 2
                columnSpacing: Kirigami.Units.smallSpacing
                rowSpacing: 0

                Accessible.description: {
                    let description = [];
                    for (let i = 0; i < children.length; i++) {
                        if (children[i].visible && children[i].hasOwnProperty("text")) {
                            description.push(children[i].text);
                        }
                    }
                    return description.join(" ");
                }

                component LeftLabel : PlasmaComponents.Label {
                    // fillWidth is true, so using internal alignment
                    horizontalAlignment: Text.AlignLeft
                    Layout.fillWidth: true
                    font: Kirigami.Theme.smallFont
                    wrapMode: Text.WordWrap
                    enabled: false
                }
                component RightLabel : PlasmaComponents.Label {
                    // fillWidth is false, so using external (grid-cell-internal) alignment
                    Layout.alignment: Qt.AlignRight
                    Layout.fillWidth: false
                    font: Kirigami.Theme.smallFont
                    enabled: false
                }

                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    Layout.columnSpan: 2

                    text: batteryItem.isBroken && typeof batteryItem.battery.Capacity !== "undefined"
                        ? i18n("This battery's health is at only %1% and it should be replaced. Contact the manufacturer.", batteryItem.battery.Capacity)
                        : ""
                    font: Kirigami.Theme.smallFont
                    color: Kirigami.Theme.neutralTextColor
                    visible: batteryItem.isBroken
                    wrapMode: Text.WordWrap
                }

                readonly property bool remainingTimeRowVisible: batteryItem.battery !== null
                    && batteryItem.remainingTime > 0
                    && batteryItem.battery["Is Power Supply"]
                    && ["Discharging", "Charging"].includes(batteryItem.battery.State)
                readonly property bool isEstimatingRemainingTime: batteryItem.battery !== null
                    && batteryItem.isPowerSupply
                    && batteryItem.remainingTime === 0
                    && batteryItem.battery.State === "Discharging"

                LeftLabel {
                    text: batteryItem.battery.State === "Charging"
                        ? i18n("Time To Full:")
                        : i18n("Remaining Time:")
                    visible: details.remainingTimeRowVisible || details.isEstimatingRemainingTime
                }

                RightLabel {
                    text: details.isEstimatingRemainingTime ? i18nc("@info", "Estimating…")
                        : KCoreAddons.Format.formatDuration(batteryItem.remainingTime, KCoreAddons.FormatTypes.HideSeconds)
                    visible: details.remainingTimeRowVisible || details.isEstimatingRemainingTime
                }

                readonly property bool healthRowVisible: batteryItem.battery !== null
                    && batteryItem.battery["Is Power Supply"]
                    && batteryItem.battery.Capacity !== ""
                    && typeof batteryItem.battery.Capacity === "number"
                    && !batteryItem.isBroken

                LeftLabel {
                    text: i18n("Battery Health:")
                    visible: details.healthRowVisible
                }

                RightLabel {
                    text: details.healthRowVisible
                        ? i18nc("Placeholder is battery health percentage", "%1%", batteryItem.battery.Capacity)
                        : ""
                    visible: details.healthRowVisible
                }
            }

        }
    }

    function stringForBatteryState(batteryData, source) {
        if (batteryData["Plugged in"]) {
            // When we are using a charge threshold, the kernel
            // may stop charging within a percentage point of the actual threshold
            // and this is considered correct behavior, so we have to handle
            // that. See https://bugzilla.kernel.org/show_bug.cgi?id=215531.
            if (typeof source.data["Battery"]["Charge Stop Threshold"] === "number"
                && (source.data.Battery.Percent >= source.data["Battery"]["Charge Stop Threshold"] - 1
                && source.data.Battery.Percent <= source.data["Battery"]["Charge Stop Threshold"] + 1)
                // Also, Upower may give us a status of "Not charging" rather than
                // "Fully charged", so we need to account for that as well. See
                // https://gitlab.freedesktop.org/upower/upower/-/issues/142.
                && (source.data["Battery"]["State"] === "NoCharge" || source.data["Battery"]["State"] === "FullyCharged")
            ) {
                return i18n("Fully Charged");
            }

            // Otherwise, just look at the charge state
            switch(batteryData["State"]) {
                case "Discharging": return i18n("Discharging");
                case "FullyCharged": return i18n("Fully Charged");
                case "Charging": return i18n("Charging");
                // when in doubt we're not charging
                default: return i18n("Not Charging");
            }
        } else {
            return i18nc("Battery is currently not present in the bay", "Not present");
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
        //ss    button.clicked()
        }
    }
}