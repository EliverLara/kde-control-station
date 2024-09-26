/*
 *   SPDX-FileCopyrightText: 2021 Kai Uwe Broulik <kde@broulik.de>
 *   SPDX-FileCopyrightText: 2021 David Redondo <kde@david-redondo.de>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.notification

PlasmaComponents3.ItemDelegate {
    id: powerProfileItem

    property alias slider: slider

    property bool profilesInstalled
    property bool profilesAvailable

    property string activeProfile
    property string activeProfileError

    property string inhibitionReason
    readonly property bool inhibited: inhibitionReason !== ""

    property string degradationReason

    // type: [{ Name: string, Icon: string, Profile: string, Reason: string }]
    required property var profileHolds

    // The canBeInhibited property mean that this profile's availability
    // depends on powerProfileItem.inhibited value (and thus on the
    // inhibitionReason string).
    readonly property var profileData: [
        {
            label: i18n("Power Save"),
            profile: "power-saver",
            canBeInhibited: false,
        }, {
            label: i18n("Balanced"),
            profile: "balanced",
            canBeInhibited: false,
        }, {
            label: i18n("Performance"),
            profile: "performance",
            canBeInhibited: true,
        }
    ]

    readonly property int activeProfileIndex: profileData.findIndex(data => data.profile === powerProfileItem.activeProfile)
    // type: typeof(profileData[])?
    readonly property var activeProfileData: activeProfileIndex !== -1 ? profileData[activeProfileIndex] : undefined
    // type: typeof(profileHolds)
    readonly property var activeHolds: profileHolds.filter(hold => hold.Profile === activeProfile)

    signal activateProfileRequested(string profile)

    background.visible: highlighted
    highlighted: activeFocus
    hoverEnabled: false
    text: i18n("Power Profile")

    Accessible.description: activeProfileLabel.text
    Accessible.role: Accessible.Slider
    Keys.forwardTo: [slider]

    Notification {
        id: powerProfileError
        componentName: "plasma_workspace"
        eventId: "warning"
        iconName: "speedometer"
        title: i18n("Power Management")
    }

    contentItem: RowLayout {
        spacing: Kirigami.Units.gridUnit

        Kirigami.Icon {
            source: "speedometer"
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents3.Label {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: powerProfileItem.text
                    textFormat: Text.PlainText
                }

                PlasmaComponents3.Label {
                    id: activeProfileLabel
                    Layout.alignment: Qt.AlignRight
                    text: !powerProfileItem.profilesAvailable ? i18nc("Power profile", "Not available") : activeProfileData ? activeProfileData.label : ""
                    textFormat: Text.PlainText
                    enabled: powerProfileItem.profilesAvailable
                }
            }

            PlasmaComponents3.Slider {
                id: slider
                visible: powerProfileItem.profilesAvailable
                Layout.fillWidth: true

                activeFocusOnTab: false
                from: 0
                to: 2
                stepSize: 1
                value: powerProfileItem.activeProfileIndex
                snapMode: PlasmaComponents3.Slider.SnapAlways
                onMoved: {
                    const { canBeInhibited, profile } = powerProfileItem.profileData[value];
                    if (!(canBeInhibited && powerProfileItem.inhibited)) {
                        console.log(profile)
                        activateProfileRequested(profile);

                    }
                }

                Connections {
                    target: powerProfileItem
                    function onActiveProfileChanged(){
                        slider.value = powerProfileItem.activeProfileIndex
                    }
                }


                Connections {
                    target: powerProfileItem
                    function onActiveProfileErrorChanged(){
                        if(powerProfileItem.activeProfileError !== "") {
                            powerProfileError.text = i18n("Failed to activate %1 mode", powerProfileItem.activeProfileError);
                            powerProfileError.sendEvent();
                            slider.value = powerProfileItem.activeProfileIndex;
                            powerProfileItem.activeProfileError = "";
                        }
                    }
                }

                // fake having a disabled second half
                Rectangle {
                    z: -1
                    visible: powerProfileItem.inhibited
                    color: Kirigami.Theme.backgroundColor
                    anchors {
                        top: parent.background.top
                        left: parent.horizontalCenter
                        leftMargin: 1
                        right: parent.right
                        bottom: parent.background.bottom
                    }
                    opacity: 0.4
                }
            }

            RowLayout {
                spacing: 0
                visible: powerProfileItem.profilesAvailable
                Layout.topMargin: Kirigami.Units.smallSpacing
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                Layout.fillWidth: true

                Kirigami.Icon {
                    Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                    Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                    source: "battery-profile-powersave-symbolic"

                    HoverHandler {
                        id: powersaveIconHover
                    }

                    PlasmaComponents3.ToolTip {
                        text: powerProfileItem.profileData.find(profile => profile.profile === "power-saver").label
                        visible: powersaveIconHover.hovered
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Kirigami.Icon {
                    Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                    Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                    source: "battery-profile-performance-symbolic"

                    HoverHandler {
                        id: performanceIconHover
                    }

                    PlasmaComponents3.ToolTip {
                        text: powerProfileItem.profileData.find(profile => profile.profile === "performance").label
                        visible: performanceIconHover.hovered
                    }
                }
            }

            // NOTE Only one of these will be visible at a time since the daemon will only set one depending
            // on its version
            InhibitionHint {
                id: inhibitionReasonHint

                Layout.fillWidth: true

                visible: powerProfileItem.inhibited
                iconSource: "dialog-information"
                text: switch(powerProfileItem.inhibitionReason) {
                    case "lap-detected":
                        return i18n("Performance mode has been disabled to reduce heat generation because the computer has detected that it may be sitting on your lap.")
                    case "high-operating-temperature":
                        return i18n("Performance mode is unavailable because the computer is running too hot.")
                    default:
                        return i18n("Performance mode is unavailable.")
                }
            }

            InhibitionHint {
                id: inhibitionPerformanceHint

                Layout.fillWidth: true

                visible: powerProfileItem.activeProfile === "performance" && powerProfileItem.degradationReason !== ""
                iconSource: "dialog-information"
                text: switch(powerProfileItem.degradationReason) {
                    case "lap-detected":
                        return i18n("Performance may be lowered to reduce heat generation because the computer has detected that it may be sitting on your lap.")
                    case "high-operating-temperature":
                        return i18n("Performance may be reduced because the computer is running too hot.")
                    default:
                        return i18n("Performance may be reduced.")
                }
            }

            InhibitionHint {
                id: inhibitionHoldersHint

                Layout.fillWidth: true

                visible: powerProfileItem.activeHolds.length > 0 && powerProfileItem.activeProfileData !== undefined
                text: powerProfileItem.activeProfileData !== undefined
                    ? i18np("One application has requested activating %2:",
                            "%1 applications have requested activating %2:",
                            powerProfileItem.activeHolds.length,
                            i18n(powerProfileItem.activeProfileData.label))
                    : ""
            }

            Repeater {
                id: repeater

                model: powerProfileItem.activeHolds

                InhibitionHint {
                    Layout.fillWidth: true

                    x: Kirigami.Units.smallSpacing
                    iconSource: modelData.Icon
                    text: i18nc("%1 is the name of the application, %2 is the reason provided by it for activating performance mode",
                                "%1: %2", modelData.Name, modelData.Reason)
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.smallSpacing

                visible: repeater.visibleChildren > 0
                    || inhibitionReasonHint.visible
                    || inhibitionPerformanceHint.visible
                    || inhibitionHoldersHint.visible
            }

            RowLayout {
                visible: !powerProfileItem.profilesInstalled
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents3.Label {
                    text: xi18n("Power profiles may be supported on your device.<nl/>Try installing the <command>power-profiles-daemon</command> package using your distribution's package manager and restarting the system.")
                    textFormat: Text.PlainText
                    enabled: false
                    font: Kirigami.Theme.smallFont
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }
            }

        }
    }
}
