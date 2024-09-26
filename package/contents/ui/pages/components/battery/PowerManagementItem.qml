/*
    SPDX-FileCopyrightText: 2012-2013 Daniel Nicoletti <dantti12@gmail.com>
    SPDX-FileCopyrightText: 2013, 2015 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.notification
import org.kde.kwindowsystem
import org.kde.plasma.components as PlasmaComponents3
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami

PlasmaComponents3.ItemDelegate {
    id: powerManagementItem

    property bool pluggedIn

    signal inhibitionChangeRequested(bool inhibit)

    property bool isManuallyInhibited
    property bool isManuallyInhibitedError
    // List of active power management inhibitions (applications that are
    // blocking sleep and screen locking).
    //
    // type: [{
    //  Name: string,
    //  PrettyName: string,
    //  Icon: string,
    //  Reason: string,
    // }]
    property var inhibitions: []
    property bool inhibitsLidAction

    property alias manualInhibitionSwitch: manualInhibitionSwitch

    background.visible: highlighted
    highlighted: activeFocus
    hoverEnabled: false
    text: i18nc("@title:group", "Sleep and Screen Locking after Inactivity")

    Notification {
        id: inhibitionError
        componentName: "plasma_workspace"
        eventId: "warning"
        iconName: "system-suspend-uninhibited"
        title: i18n("Power Management")
    }

    Accessible.description: pmStatusLabel.text
    Accessible.role: Accessible.CheckBox
    KeyNavigation.tab: manualInhibitionSwitch

    contentItem: RowLayout {
        spacing: Kirigami.Units.gridUnit
        
        Kirigami.Icon {
            id: icon
            source: powerManagementItem.isManuallyInhibited || powerManagementItem.inhibitions.length > 0 ? "system-suspend-inhibited" : "system-suspend-uninhibited"
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
        }

        ColumnLayout {
          //  Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
               // Layout.fillWidth: true
                spacing: Kirigami.Units.largeSpacing
                Layout.maximumWidth: root.fullRepWidth - 70
                PlasmaComponents3.Label {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: powerManagementItem.text
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                }

                PlasmaComponents3.Label {
                    id: pmStatusLabel
                    Layout.alignment: Qt.AlignRight | Qt.AlignTop
                    text: powerManagementItem.isManuallyInhibited || powerManagementItem.inhibitions.length > 0 ? i18nc("Sleep and Screen Locking after Inactivity", "Blocked") : i18nc("Sleep and Screen Locking after Inactivity", "Automatic")
                    textFormat: Text.PlainText
                }
            }

            RowLayout {
                // UI to manually inhibit sleep and screen locking
                PlasmaComponents3.Switch {
                    id: manualInhibitionSwitch
                    Layout.fillWidth: true
                    text: i18nc("@option:check Manually block sleep and screen locking after inactivity", "Manually block")
                    checked: powerManagementItem.isManuallyInhibited
                    focus: true

                    KeyNavigation.up: powerManagementItem.KeyNavigation.up
                    KeyNavigation.down: powerManagementItem.KeyNavigation.down
                    KeyNavigation.tab: powerManagementItem.KeyNavigation.down
                    KeyNavigation.backtab: powerManagementItem.KeyNavigation.backtab

                    Keys.onPressed: (event) => {
                        if (event.key == Qt.Key_Space || event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
                            toggle();
                        }
                    }

                    onToggled: {
                        inhibitionChangeRequested(checked);
                    }

                    Connections {
                        target: powerManagementItem
                        function onIsManuallyInhibitedChanged() {
                            manualInhibitionSwitch.checked = isManuallyInhibited;
                        }
                    }

                    Connections {
                        target: powerManagementItem
                        function onIsManuallyInhibitedErrorChanged() {
                            if (powerManagementItem.isManuallyInhibitedError) {
                                manualInhibitionSwitch.checked = !manualInhibitionSwitch.checked
                                busyIndicator.visible = false;
                                powerManagementItem.isManuallyInhibitedError = false;
                                if (!powerManagementItem.isManuallyInhibited) {
                                    inhibitionError.text = i18n("Failed to unblock automatic sleep and screen locking");
                                    inhibitionError.sendEvent();
                                } else {
                                    inhibitionError.text = i18n("Failed to block automatic sleep and screen locking");
                                    inhibitionError.sendEvent();
                                }
                            }
                        }
                    }
                }

            BusyIndicator {
                id: busyIndicator
                visible: false
                Layout.preferredHeight: manualInhibitionSwitch.implicitHeight

                Connections {
                    target: powerManagementItem

                    function onInhibitionChangeRequested(inhibit) {
                        busyIndicator.visible = inhibit != powerManagementItem.isManuallyInhibited;
                    }

                    function onIsManuallyInhibitedChanged(val) {
                        busyIndicator.visible = false;
                    }
                }
            }
        }

            // list of automatic inhibitions
            ColumnLayout {
                id: inhibitionReasonsLayout

                Layout.fillWidth: false
                visible: powerManagementItem.inhibitsLidAction || (powerManagementItem.inhibitions.length > 0)

                InhibitionHint {
                  anchors.fill:parent
                    visible: powerManagementItem.inhibitsLidAction
                    iconSource: "computer-laptop"
                    text: i18nc("Minimize the length of this string as much as possible", "Your laptop is configured not to sleep when closing the lid while an external monitor is connected.")
                }

                PlasmaComponents3.Label {
                    id: inhibitionExplanation
                    Layout.fillWidth: true
                    visible: powerManagementItem.inhibitions.length > 1
                    font: Kirigami.Theme.smallFont
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    maximumLineCount: 3
                    text: i18np("%1 application is currently blocking sleep and screen locking:",
                                "%1 applications are currently blocking sleep and screen locking:",
                                powerManagementItem.inhibitions.length)
                    textFormat: Text.PlainText
                }

                Repeater {
                    model: powerManagementItem.inhibitions

                    InhibitionHint {
                        property string icon: modelData.Icon
                            || (KWindowSystem.isPlatformWayland ? "wayland" : "xorg")
                        property string name: modelData.PrettyName
                        property string reason: modelData.Reason

                        Layout.fillWidth: true
                        iconSource: icon
                        text: {
                            if (powerManagementItem.inhibitions.length === 1) {
                                if (reason && name) {
                                    return i18n("%1 is currently blocking sleep and screen locking (%2)", name, reason)
                                } else if (name) {
                                    return i18n("%1 is currently blocking sleep and screen locking (unknown reason)", name)
                                } else if (reason) {
                                    return i18n("An application is currently blocking sleep and screen locking (%1)", reason)
                                } else {
                                    return i18n("An application is currently blocking sleep and screen locking (unknown reason)")
                                }
                            } else {
                                if (reason && name) {
                                    return i18nc("Application name: reason for preventing sleep and screen locking", "%1: %2", name, reason)
                                } else if (name) {
                                    return i18nc("Application name: reason for preventing sleep and screen locking", "%1: unknown reason", name)
                                } else if (reason) {
                                    return i18nc("Application name: reason for preventing sleep and screen locking", "Unknown application: %1", reason)
                                } else {
                                    return i18nc("Application name: reason for preventing sleep and screen locking", "Unknown application: unknown reason")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
