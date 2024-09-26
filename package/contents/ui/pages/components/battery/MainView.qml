import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.kquickcontrolsaddons 2.1
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras

PlasmaComponents3.ScrollView {
        id: scrollView

        focus: false


        property alias model: batteryRepeater.model
        property bool pluggedIn

        property int remainingTime

        property bool isBrightnessAvailable
        property bool isKeyboardBrightnessAvailable

        property string activeProfile
        property var profiles

        property alias profilesInstalled: powerProfileItem.profilesInstalled
        property alias activeProfileError: powerProfileItem.activeProfileError

        property int chargeStopThreshold: 0

        // List of active power management inhibitions (applications that are
        // blocking sleep and screen locking).
        //
        // type: [{
        //  Icon: string,
        //  Name: string,
        //  Reason: string,
        // }]
        property var inhibitions: []
        property bool inhibitsLidAction

        property string inhibitionReason
        property string degradationReason
        // type: [{ Name: string, Icon: string, Profile: string, Reason: string }]
        required property var profileHolds

        property alias isManuallyInhibited: pmSwitch.isManuallyInhibited
        property alias isManuallyInhibitedError: pmSwitch.isManuallyInhibited

        signal inhibitionChangeRequested(bool inhibit)
        signal activateProfileRequested(string profile)

        // HACK: workaround for https://bugreports.qt.io/browse/QTBUG-83890
        PlasmaComponents3.ScrollBar.horizontal.policy: PlasmaComponents3.ScrollBar.AlwaysOff

        function positionViewAtItem(item) {
            if (!PlasmaComponents3.ScrollBar.vertical.visible) {
                return;
            }
            const rect = batteryList.mapFromItem(item, 0, 0, item.width, item.height);
            if (rect.y < scrollView.contentItem.contentY) {
                scrollView.contentItem.contentY = rect.y;
            } else if (rect.y + rect.height > scrollView.contentItem.contentY + scrollView.height) {
                scrollView.contentItem.contentY = rect.y + rect.height - scrollView.height;
            }
        }

        Column {
            id: batteryList

            spacing: PlasmaCore.Units.smallSpacing * 2

            readonly property Item firstHeaderItem: {
                if (powerProfileItem.visible) {
                    return powerProfileItem;
                }
                return null;
            }
            readonly property Item lastHeaderItem: {
                if (powerProfileItem.visible) {
                    return powerProfileItem;
                }
                return null;
            }

            PowerProfileItem {
                id: powerProfileItem

                width: scrollView.availableWidth

              //  KeyNavigation.up: keyboardBrightnessSlider.visible ? keyboardBrightnessSlider : keyboardBrightnessSlider.KeyNavigation.up
                KeyNavigation.down: batteryRepeater.count > 0 ? batteryRepeater.itemAt(0) : null
                KeyNavigation.backtab: KeyNavigation.up
                KeyNavigation.tab: KeyNavigation.down

                activeProfile: scrollView.activeProfile
                inhibitionReason: scrollView.inhibitionReason
                visible: scrollView.profiles.length > 0
                degradationReason: scrollView.degradationReason
                profileHolds: scrollView.profileHolds
                profilesAvailable: scrollView.profiles.length > 0
                onActivateProfileRequested: scrollView.activateProfileRequested(profile)
                onActiveFocusChanged: if (activeFocus) scrollView.positionViewAtItem(this)
            }

            Repeater {
                id: batteryRepeater

                delegate: BatteryItem {
                    width: scrollView.availableWidth

                    battery: model
                    remainingTime: scrollView.remainingTime
                    //matchHeightOfSlider: brightnessSlider.slider

                    KeyNavigation.up: index === 0 ? batteryList.lastHeaderItem : batteryRepeater.itemAt(index - 1)
                    KeyNavigation.down: index + 1 < batteryRepeater.count ? batteryRepeater.itemAt(index + 1) : null
                    KeyNavigation.backtab: KeyNavigation.up
                    KeyNavigation.tab: KeyNavigation.down

                    Keys.onTabPressed: {
                        if (index === batteryRepeater.count - 1) {
                            // Workaround to leave applet's focus on desktop
                            nextItemInFocusChain(false).forceActiveFocus(Qt.TabFocusReason);
                        } else {
                            event.accepted = false;
                        }
                    }

                    onActiveFocusChanged: if (activeFocus) scrollView.positionViewAtItem(this)
                }
            }

            PowerManagementItem {
                
                id: pmSwitch

                inhibitions: scrollView.inhibitions
                inhibitsLidAction: scrollView.inhibitsLidAction
                pluggedIn: scrollView.pluggedIn
                onInhibitionChangeRequested: scrollView.inhibitionChangeRequested(inhibit)
            }
        }
    }