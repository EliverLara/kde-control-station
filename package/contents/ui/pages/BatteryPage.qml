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

    PowerProfilesControl {
        id: powerProfilesControl

        readonly property bool isInBalancedProfile: powerProfilesControl.activeProfile === "balanced"
        readonly property bool isInPerformanceProfile: powerProfilesControl.activeProfile === "performance"
        readonly property bool isInPowersaveProfile: powerProfilesControl.activeProfile === "power-saver"
        readonly property bool isHeldOnPowerProfile: powerProfilesControl.profileHolds.length > 0
        readonly property string defaultPowerProfile: powerProfilesControl.configuredProfile ? powerProfilesControl.configuredProfile : "balanced"
        readonly property bool isInNonDefaultPowerProfile: powerProfilesControl.activeProfile && powerProfilesControl.activeProfile != powerProfilesControl.defaultPowerProfile
    }

    BatteryControlModel {
        id: batteryControl

        readonly property int remainingTime: batteryControl.smoothedRemainingMsec
        readonly property bool isSomehowFullyCharged: batteryControl.pluggedIn && batteryControl.state === BatteryControlModel.FullyCharged
    }

    PowerManagementControl {
        id: powerManagementControl
    }

    readonly property bool kcmAuthorized: KAuthorized.authorizeControlModule("powerdevilprofilesconfig")
    readonly property bool kcmEnergyInformationAuthorized: KAuthorized.authorizeControlModule("kcm_energyinfo")

    signal inhibitionChangeRequested(bool inhibit)

    onInhibitionChangeRequested: inhibit => {

        powerManagementControl.isSilent = root.expanded; // show OSD only when the plasmoid isn't expanded since the changing switch is feedback enough

        if (inhibit) {
            const reason = i18n("The battery applet has enabled suppressing sleep and screen locking");
            powerManagementControl.inhibit(reason)
        } else {
            powerManagementControl.uninhibit()
        }
    }

    signal activateProfileRequested(string profile)

    onActivateProfileRequested: profile => {
        console.log(profile)
        powerProfilesControl.isSilent = root.expanded;

        if (profile === powerProfilesControl.activeProfile) {
            return;
        }
        powerProfilesControl.setProfile(profile);
    }

    sectionTitle: batteryControl.hasBatteries ? i18n("Power and Battery") : i18n("Power Management")

    BatteryComponents.MainView {
        anchors.fill: parent

        model: batteryControl

        isManuallyInhibited: powerManagementControl.isManuallyInhibited
        isManuallyInhibitedError: powerManagementControl.isManuallyInhibitedError
        pluggedIn: batteryControl.pluggedIn
        chargeStopThreshold: batteryControl.chargeStopThreshold
        remainingTime: batteryControl.remainingTime
        activeProfile: powerProfilesControl.activeProfile
        activeProfileError: powerProfilesControl.profileError
        inhibitions: powerManagementControl.inhibitions
        inhibitsLidAction: powerManagementControl.isLidPresent && !powerManagementControl.triggersLidAction
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