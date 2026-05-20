/*
    SPDX-FileCopyrightText: 2013-2014 Jan Grulich <jgrulich@redhat.com>
    SPDX-FileCopyrightText: 2014-2015 David Rosca <nowrep@gmail.com>
    SPDX-FileCopyrightText: 2020 Nate Graham <nate@kde.org>
    SPDX-FileCopyrightText: 2024 ivan tkachenko <me@ratijas.tk>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.bluezqt as BluezQt
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrolsaddons as KQuickControlsAddons
import org.kde.ksvg as KSvg
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.private.bluetooth as PlasmaBt

PlasmaExtras.ExpandableListItem {
    id: root

    required property int index
    required property var model

    required property var forgetDeviceDialog

    property list<string> currentDeviceDetails

    icon: model.Icon
    title: model.DeviceFullName
    subtitle: infoText()
    isBusy: model.Connecting
    isDefault: model.Connected
    defaultActionButtonAction: QQC2.Action {
        icon.name: root.model.Connected ? "network-disconnect-symbolic" : "network-connect-symbolic"
        text: root.model.Connected ? i18n("Disconnect") : i18n("Connect")
        onTriggered: source => {
            root.toggleDevice();
        }
    }

    contextualActions: [
        QQC2.Action {
            id: browseFilesButton
            enabled: root.model.Uuids.indexOf(BluezQt.Services.ObexFileTransfer) !== -1
            icon.name: "folder-symbolic"
            text: i18n("Browse Files")

            onTriggered: source => {
                const url = "obexftp://%1/".arg(root.model.Address.replace(/:/g, "-"));
                Qt.openUrlExternally(url);
            }
        },
        QQC2.Action {
            id: sendFileButton
            enabled: root.model.Uuids.indexOf(BluezQt.Services.ObexObjectPush) !== -1
            icon.name: "document-share-symbolic"
            text: i18n("Send File")

            onTriggered: source => {
                PlasmaBt.LaunchApp.launchSendFile(root.model.Ubi);
            }
        },
        QQC2.Action {
            id: forgetDeviceAction
            enabled: root.model.Paired
            icon.name: "edit-delete-remove-symbolic"
            text: i18nc("@action:button Forget a Bluetooth device", "Forget")

            onTriggered: source => {
                root.forgetDeviceDialog.open(root.model.Device);
            }
        }
    ]

    customExpandedViewContent: Component {
        id: expandedView

        ColumnLayout {
            spacing: 0

            // Media Player
            MediaPlayerItem {
                id: mediaPlayerItem
                mediaPlayer: root.model.MediaPlayer
                Layout.leftMargin: Kirigami.Units.gridUnit + Kirigami.Units.smallSpacing * 3
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                Layout.fillWidth: true
                visible: mediaPlayer !== null
            }

            KSvg.SvgItem {
                Layout.fillWidth: true
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                imagePath: "widgets/line"
                elementId: "horizontal-line"
                visible: mediaPlayerItem.visible
                    || (!mediaPlayerItem.visible && !(browseFilesButton.enabled || sendFileButton.enabled))
            }

            KQuickControlsAddons.Clipboard {
                id: clipboard
            }

            PlasmaExtras.Menu {
                id: contextMenu
                property string text

                function show(visualParent: Item, text: string, x: real, y: real) {
                    this.visualParent = visualParent;
                    this.text = text;
                    open(x, y);
                }

                PlasmaExtras.MenuItem {
                    text: i18n("Copy")
                    icon: "edit-copy-symbolic"
                    enabled: contextMenu.text !== ""
                    onClicked: clipboard.content = contextMenu.text
                }
            }

            // Details
            MouseArea {
                Layout.fillWidth: true
                Layout.preferredHeight: detailsGrid.implicitHeight

                acceptedButtons: Qt.RightButton
                activeFocusOnTab: repeater.count > 0

                Accessible.description: {
                    const description = [];
                    for (let i = 0; i < root.currentDeviceDetails.length; i += 2) {
                        description.push(root.currentDeviceDetails[i]);
                        description.push(": ");
                        description.push(root.currentDeviceDetails[i + 1]);
                        description.push("; ");
                    }
                    return description.join('');
                }

                onPressed: mouse => {
                    const item = detailsGrid.childAt(mouse.x, mouse.y) as PlasmaComponents3.Label;
                    if (!item || !item.isContent) {
                        return; // only let users copy the value on the right
                    }

                    contextMenu.show(this, item.text, mouse.x, mouse.y);
                }

                Loader {
                    anchors.fill: parent
                    active: parent.activeFocus
                    asynchronous: true
                    z: -1

                    sourceComponent: PlasmaExtras.Highlight {
                        hovered: true
                    }
                }

                GridLayout {
                    id: detailsGrid
                    width: parent.width
                    columns: 2
                    rowSpacing: Kirigami.Units.smallSpacing / 4

                    Repeater {
                        id: repeater

                        model: root.currentDeviceDetails

                        PlasmaComponents3.Label {
                            id: detailLabel

                            required property int index
                            required property string modelData

                            readonly property bool isContent: index % 2

                            Layout.fillWidth: true

                            horizontalAlignment: isContent ? Text.AlignLeft : Text.AlignRight
                            elide: isContent ? Text.ElideRight : Text.ElideNone
                            font: Kirigami.Theme.smallFont
                            opacity: isContent ? 1 : 0.6
                            text: isContent ? modelData : `${modelData}:`
                            textFormat: isContent ? Text.PlainText : Text.StyledText
                        }
                    }
                }
            }

            Component.onCompleted: {
                root.createContent();
            }
        }
    }

    // Hide device details when the device for this delegate changes
    // This happens eg. when device connects/disconnects
    property BluezQt.Device __device: model.Device
    // React to both model and model.Device changes at once
    on__DeviceChanged: {
        collapse();
        if (ListView.view.currentIndex === index) {
            ListView.view.currentIndex = -1;
        }
    }

    function boolToString(value: bool): string {
        return value ? i18n("Yes") : i18n("No");
    }

    function adapterName(adapter: BluezQt.Adapter): string {
        const hci = PlasmaBt.Utils.adapterHciString(adapter.ubi);
        return (hci !== "")
            ? i18nc("@label %1 is human-readable adapter name, %2 is HCI", "%1 (%2)", adapter.name, hci)
            : adapter.name;
    }

    function createContent(): void {
        const details = [];

        if (model.Name !== model.RemoteName) {
            details.push(i18n("Remote Name"));
            details.push(model.RemoteName);
        }

        details.push(i18n("Address"));
        details.push(model.Address);

        details.push(i18n("Paired"));
        details.push(boolToString(model.Paired));

        details.push(i18n("Trusted"));
        details.push(boolToString(model.Trusted));

        details.push(i18n("Adapter"));
        details.push(adapterName(model.Adapter));

        currentDeviceDetails = details;
    }

    function infoText(): string {
        if (model.Connecting) {
            return model.Connected ? i18n("Disconnecting") : i18n("Connecting");
        }

        const labels = [];

        if (model.Connected) {
            labels.push(i18n("Connected"));
        } else if (model.ConnectionFailed) {
            labels.push(i18n("Connection failed"));
        }

        switch (model.Type) {
        case BluezQt.Device.Headset:
        case BluezQt.Device.Headphones:
        case BluezQt.Device.OtherAudio:
            labels.push(i18n("Audio device"));
            break;

        case BluezQt.Device.Keyboard:
        case BluezQt.Device.Mouse:
        case BluezQt.Device.Joypad:
        case BluezQt.Device.Tablet:
            labels.push(i18n("Input device"));
            break;

        case BluezQt.Device.Phone:
            labels.push(i18n("Phone"));
            break;

        default:
            const profiles = [];

            if (model.Uuids.indexOf(BluezQt.Services.ObexFileTransfer) !== -1) {
                profiles.push(i18n("File transfer"));
            }
            if (model.Uuids.indexOf(BluezQt.Services.ObexObjectPush) !== -1) {
                profiles.push(i18n("Send file"));
            }
            if (model.Uuids.indexOf(BluezQt.Services.HumanInterfaceDevice) !== -1) {
                profiles.push(i18n("Input"));
            }
            if (model.Uuids.indexOf(BluezQt.Services.AdvancedAudioDistribution) !== -1) {
                profiles.push(i18n("Audio"));
            }
            if (model.Uuids.indexOf(BluezQt.Services.Nap) !== -1) {
                profiles.push(i18n("Network"));
            }

            if (profiles.length === 0) {
                // None of the above
                profiles.push(i18n("Other device"));
            }

            labels.push(profiles.join(", "));
        }

        if (model.Battery) {
            labels.push(i18n("%1% Battery", model.Battery.percentage));
        }

        return labels.join(" · ");
    }

    function toggleDevice(): void {
        if (model.Connecting) {
            return;
        }

        const /*PendingCall*/call = model.Connected
            ? model.Device.disconnectFromDevice()
            : model.Device.connectToDevice();

        PlasmaBt.SharedDevicesStateProxyModel.registerPendingCallForDeviceUbi(call, model.Ubi);
    }
}
