import QtQuick 2.15
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.15

import org.kde.coreaddons as KCoreAddons
import org.kde.kcmutils // KCMLauncher
import org.kde.config // KAuthorized
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels

import org.kde.plasma.private.batterymonitor
import org.kde.plasma.private.battery
import org.kde.plasma.components as PlasmaComponents3


import "../lib" as Lib
import "components/battery" as BatteryComponents

PageTemplate {
    id: batterymonitor

    property var contentItemHeight: mainView.implicitContentHeight

    PowerProfilesControl {
        id: powerProfilesControl

        readonly property bool isInBalancedProfile: powerProfilesControl.activeProfile === "balanced"
        readonly property bool isInPerformanceProfile: powerProfilesControl.activeProfile === "performance"
        readonly property bool isInPowersaveProfile: powerProfilesControl.activeProfile === "power-saver"
        readonly property bool isHeldOnPowerProfile: powerProfilesControl.profileHolds.length > 0
        readonly property string defaultPowerProfile: powerProfilesControl.configuredProfile ? powerProfilesControl.configuredProfile : "balanced"
        readonly property bool isInNonDefaultPowerProfile: powerProfilesControl.activeProfile && powerProfilesControl.activeProfile != powerProfilesControl.defaultPowerProfile
    }

    property BatteryControlModel batteryControl: BatteryControlModel {
        id: batteryControl

        readonly property int remainingTime: batteryControl.smoothedRemainingMsec
        readonly property bool isSomehowFullyCharged: batteryControl.pluggedIn && batteryControl.state === BatteryControlModel.FullyCharged
    }

    property var possibleInhibitionControls: [
        `
            import org.kde.plasma.private.batterymonitor
            PowerManagementControl {
                id: inhibitionControl
            }
        `,
        `
            import org.kde.plasma.private.batterymonitor
            InhibitionControl {
                id: inhibitionControl
            }
        `
    ]

    property var inhibitionControl: Qt.createQmlObject(
        root.plasmaVersion < 3 ? possibleInhibitionControls[0] : possibleInhibitionControls[1], 
        batterymonitor, 
        "inhibitionControl"
    )

    readonly property bool kcmAuthorized: KAuthorized.authorizeControlModule("powerdevilprofilesconfig")
    readonly property bool kcmEnergyInformationAuthorized: KAuthorized.authorizeControlModule("kcm_energyinfo")

    signal inhibitionChangeRequested(bool inhibit)

    onInhibitionChangeRequested: inhibit => {

        inhibitionControl.isSilent = root.expanded; // show OSD only when the plasmoid isn't expanded since the changing switch is feedback enough

        if (inhibit) {
            const reason = i18n("The battery applet has enabled suppressing sleep and screen locking");
            inhibitionControl.inhibit(reason)
        } else {
            inhibitionControl.uninhibit()
        }
    }

    signal activateProfileRequested(string profile)

    onActivateProfileRequested: profile => {
        powerProfilesControl.isSilent = root.expanded;

        if (profile === powerProfilesControl.activeProfile) {
            return;
        }
        powerProfilesControl.setProfile(profile);
    }

    sectionTitle: batteryControl.hasBatteries ? i18n("Power and Battery") : i18n("Power Management")
    
    BatteryComponents.MainView {
        id: mainView
        anchors.fill: parent

        model: batteryControl

        isManuallyInhibited: inhibitionControl.isManuallyInhibited
        isManuallyInhibitedError: inhibitionControl.isManuallyInhibitedError
        pluggedIn: batteryControl.pluggedIn
        chargeStopThreshold: batteryControl.chargeStopThreshold
        remainingTime: batteryControl.remainingTime
        activeProfile: powerProfilesControl.activeProfile
        activeProfileError: powerProfilesControl.profileError
        inhibitions: (inhibitionControl.requestedInhibitions ?? inhibitionControl.inhibitions ?? []).filter(inhibition => inhibition.active !== false)
        inhibitsLidAction: inhibitionControl.isLidPresent && !inhibitionControl.triggersLidAction
        profilesInstalled: powerProfilesControl.isPowerProfileDaemonInstalled
        profiles: powerProfilesControl.profiles
        inhibitionReason: powerProfilesControl.inhibitionReason
        degradationReason: powerProfilesControl.degradationReason
        profileHolds: powerProfilesControl.profileHolds

        onActivateProfileRequested: profile => {
            batterymonitor.activateProfileRequested(profile);
        }

        onInhibitionChangeRequested: inhibit => {
            batterymonitor.inhibitionChangeRequested(inhibit);
        }
    }
}