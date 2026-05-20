import QtQuick
import QtQuick.Controls as QQC2

import org.kde.bluedevil.components as BluedevilComponents
import org.kde.bluezqt as BluezQt
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid
import org.kde.plasma.private.bluetooth as PlasmaBt

import "../lib" as Lib
import "components/bluetooth" as BluetoothComponents

PageTemplate {
    id: bluetoothPage

    sectionTitle: i18n("Bluetooth")
    extraHeaderItems: header

    readonly property alias addDeviceAction: addDeviceAction
    readonly property alias toggleBluetoothAction: toggleBluetoothAction

    readonly property bool emptyList: BluezQt.Manager.devices.length === 0
    
    readonly property var oldDevicesModel: PlasmaBt.DevicesProxyModel {
        id: oldDevicesModel
        sourceModel: BluezQt.DevicesModel { }
    }

    PlasmaBt.DevicesProxyModel {
        id: devicesModel
     //   hideBlockedDevices: true
        sourceModel: PlasmaBt.SharedDevicesStateProxyModel
    }

    function setBluetoothEnabled(enable: bool): void {
        BluezQt.Manager.bluetoothBlocked = !enable;

        BluezQt.Manager.adapters.forEach(adapter => {
            adapter.powered = enable;
        });
    }

    PlasmaCore.Action {
        id: toggleBluetoothAction
        text: i18n("Enable")
        icon.name: "preferences-system-bluetooth-symbolic"
        priority: PlasmaCore.Action.LowPriority
        checkable: true
        checked: BluezQt.Manager.bluetoothOperational
        visible: BluezQt.Manager.bluetoothBlocked || BluezQt.Manager.adapters.length > 0
        onTriggered: checked => {
            setBluetoothEnabled(checked);
        }
    }

     PlasmaCore.Action {
        id: addDeviceAction
        text: i18n("Pair Device…")
        icon.name: "list-add-symbolic"
        visible: !BluezQt.Manager.bluetoothBlocked
        onTriggered: checked => PlasmaBt.LaunchApp.launchWizard()
    }

    BluetoothComponents.Header {
        id: header
    }

    readonly property alias forgetDialog: forgetDialogInstance

    BluedevilComponents.ForgetDeviceDialog {
        id: forgetDialogInstance
        parent: bluetoothPage
        registerCallForDeviceUbi: (call, ubi) => {
            PlasmaBt.SharedDevicesStateProxyModel.registerDisconnectingCallForDeviceUbi(call, ubi);
        }
    }

    QQC2.Action {
        id: addBluetoothDeviceAction

        text: addDeviceAction.text
        icon.name: addDeviceAction.icon.name

        onTriggered: source => addDeviceAction.trigger()
    }

    // Unlike the associated Plasma Action, this one is for a non-checkable button
    QQC2.Action {
        id: toggleBluetoothActionLocal

        text: i18n("Enable")
        icon.name: toggleBluetoothAction.icon.name

        onTriggered: source => toggleBluetoothAction.trigger()
    }    


    PlasmaComponents3.ScrollView {
        id: scrollView
        anchors.fill: parent

        // HACK: workaround for https://bugreports.qt.io/browse/QTBUG-83890
        PlasmaComponents3.ScrollBar.horizontal.policy: PlasmaComponents3.ScrollBar.AlwaysOff

        contentWidth: availableWidth - contentItem.leftMargin - contentItem.rightMargin

        contentItem: ListView {
            id: listView

            model: (BluezQt.Manager.adapters.length > 0 && !BluezQt.Manager.bluetoothBlocked) ? root.plasmaVersion < 2 ? oldDevicesModel : devicesModel : null
            clip: true
            currentIndex: -1
            boundsBehavior: Flickable.StopAtBounds

            spacing: Kirigami.Units.smallSpacing
            topMargin: Kirigami.Units.largeSpacing
            leftMargin: Kirigami.Units.largeSpacing
            rightMargin: Kirigami.Units.largeSpacing
            bottomMargin: Kirigami.Units.largeSpacing

            section.property: "Section"
            // We want to hide the section delegate for the "Connected"
            // group because it's unnecessary; all we want to do here is
            // separate the connected devices from the available ones
            section.delegate: Loader {
                required property string section

                active: section !== "Connected" && BluezQt.Manager.connectedDevices.length > 0

                width: ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin
                // Need to manually set the height or else the loader takes up
                // space after the first time it unloads a previously-loaded item
                height: active ? Kirigami.Units.gridUnit : 0

                // give us 2 frames to try and figure out a layout, this reduces jumpyness quite a bit but doesn't
                // entirely eliminate it https://bugs.kde.org/show_bug.cgi?id=438610
                Behavior on height { PropertyAnimation { duration: 32 } }

                sourceComponent: Item {
                    KSvg.SvgItem {
                        width: parent.width - Kirigami.Units.gridUnit * 2
                        anchors.centerIn: parent
                        imagePath: "widgets/line"
                        elementId: "horizontal-line"
                    }
                }
            }
            highlight: PlasmaExtras.Highlight {}
            highlightMoveDuration: Kirigami.Units.shortDuration
            highlightResizeDuration: Kirigami.Units.shortDuration
            delegate: BluetoothComponents.DeviceItem {
                forgetDeviceDialog: bluetoothPage.forgetDialog
            }

            Keys.onUpPressed: event => {
                if (listView.currentIndex === 0) {
                    listView.currentIndex = -1;
                    toolbar.onSwitch.forceActiveFocus(Qt.BacktabFocusReason);
                } else {
                    event.accepted = false;
                }
            }

            Loader {
                anchors.centerIn: parent
                width: parent.width - (4 * Kirigami.Units.gridUnit)
                active: BluezQt.Manager.rfkill.state === BluezQt.Rfkill.Unknown || BluezQt.Manager.bluetoothBlocked || bluetoothPage.emptyList
                sourceComponent: PlasmaExtras.PlaceholderMessage {
                    iconName: BluezQt.Manager.rfkill.state === BluezQt.Rfkill.Unknown || BluezQt.Manager.bluetoothBlocked ? "network-bluetooth" : "network-bluetooth-activated"

                    text: {
                        // We cannot use the adapter count here because that can be zero when
                        // bluetooth is disabled even when there are physical devices
                        if (BluezQt.Manager.rfkill.state === BluezQt.Rfkill.Unknown) {
                            return i18n("No Bluetooth adapters available");
                        } else if (BluezQt.Manager.bluetoothBlocked) {
                            return i18n("Bluetooth is disabled");
                        } else if (bluetoothPage.emptyList) {
                            return i18n("No devices paired");
                        } else {
                            return "";
                        }
                    }

                    helpfulAction: {
                        if (BluezQt.Manager.rfkill.state === BluezQt.Rfkill.Unknown) {
                            return null;
                        } else if (BluezQt.Manager.bluetoothBlocked) {
                            return toggleBluetoothActionLocal;
                        } else if (bluetoothPage.emptyList) {
                            return addBluetoothDeviceAction;
                        } else {
                            return null;
                        }
                    }
                }
            }
        }
    }
}