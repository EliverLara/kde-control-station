import QtQuick 2.15
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.15
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM// KCMLauncher
import org.kde.config as KConfig  // KAuthorized.authorizeControlModule
import org.kde.ksvg as KSvg
import org.kde.plasma.extras as PlasmaExtras

import org.kde.plasma.private.volume

import "../lib" as Lib
import "components/volume" as VolumeComponents
PageTemplate {
    id: volumePage

    sectionTitle: i18n("Audio Volume")

    GlobalConfig {
        id: config
    }

    property bool volumeFeedback: config.audioFeedback
    property bool globalMute: config.globalMute
    property string displayName: i18n("Audio Volume")
    property QtObject draggedStream: null

    property bool showVirtualDevices: true

    property string currentTab: "devices"

    // DEFAULT_SINK_NAME in module-always-sink.c
    readonly property string dummyOutputName: "auto_null"
    readonly property string noDevicePlaceholderMessage: i18n("No output or input devices found")

    function nodeName(pulseObject) {
        const nodeNick = pulseObject.pulseProperties["node.nick"]
        if (nodeNick) {
            return nodeNick
        }

        if (pulseObject.description) {
            return pulseObject.description
        }

        if (pulseObject.name) {
            return pulseObject.name
        }

        return i18n("Device name not found")
    }

    function isDummyOutput(output) {
        return output && output.name === dummyOutputName;
    }

    function volumePercent(volume) {
        return Math.round(volume / PulseAudio.NormalVolume * 100.0);
    }

    function playFeedback(sinkIndex) {
        if (!volumeFeedback) {
            return;
        }
        if (sinkIndex == undefined) {
            sinkIndex = PreferredDevice.sink.index;
        }
        feedback.play(sinkIndex);
    }

    // Output devices
    readonly property SinkModel paSinkModel: SinkModel { id: paSinkModel }

    // Input devices
    readonly property SourceModel paSourceModel: SourceModel { id: paSourceModel }

    // Confusingly, Sink Input is what PulseAudio calls streams that send audio to an output device
    readonly property SinkInputModel paSinkInputModel: SinkInputModel { id: paSinkInputModel }

    // Confusingly, Source Output is what PulseAudio calls streams that take audio from an input device
    readonly property SourceOutputModel paSourceOutputModel: SourceOutputModel { id: paSourceOutputModel }

        // active output devices
    readonly property PulseObjectFilterModel paSinkFilterModel: PulseObjectFilterModel {
        id: paSinkFilterModel
        filterOutInactiveDevices: true
        filterVirtualDevices: !volumePage.showVirtualDevices
        sourceModel: paSinkModel
    }

    // active input devices
    readonly property PulseObjectFilterModel paSourceFilterModel: PulseObjectFilterModel {
        id: paSourceFilterModel
        filterOutInactiveDevices: true
        filterVirtualDevices: !volumePage.showVirtualDevices
        sourceModel: paSourceModel
    }

    // non-virtual streams going to output devices
    readonly property PulseObjectFilterModel paSinkInputFilterModel: PulseObjectFilterModel {
        id: paSinkInputFilterModel
        filters: [ { role: "VirtualStream", value: false } ]
        sourceModel: paSinkInputModel
    }

    // non-virtual streams coming from input devices
    readonly property PulseObjectFilterModel paSourceOutputFilterModel: PulseObjectFilterModel {
        id: paSourceOutputFilterModel
        filters: [ { role: "VirtualStream", value: false } ]
        sourceModel: paSourceOutputModel
    }

    readonly property CardModel paCardModel: CardModel {
        id: paCardModel

        function indexOfCardNumber(cardNumber) {
            const indexRole = KItemModels.KRoleNames.role("Index");
            for (let idx = 0; idx < count; ++idx) {
                if (data(index(idx, 0), indexRole) === cardNumber) {
                    return index(idx, 0);
                }
            }
            return index(-1, 0);
        }
    }

    VolumeFeedback {
        id: feedback
    }

    ColumnLayout {

        spacing: Kirigami.Units.gridUnit
        anchors.fill: parent

        RowLayout {
            //anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing

            PC3.TabBar {
                id: tabBar
                Layout.fillWidth: true
                //Layout.fillHeight: true

                currentIndex: {
                    switch (volumePage.currentTab) {
                    case "devices":
                        return devicesTab.PC3.TabBar.index;
                    case "streams":
                        return streamsTab.PC3.TabBar.index;
                    }
                }

                KeyNavigation.down: contentView.currentItem.contentItem.upperListView.itemAtIndex(0)

                onCurrentIndexChanged: {
                    switch (currentIndex) {
                    case devicesTab.PC3.TabBar.index:
                        volumePage.currentTab = "devices";
                        break;
                    case streamsTab.PC3.TabBar.index:
                        volumePage.currentTab = "streams";
                        break;
                    }
                }

                PC3.TabButton {
                    id: devicesTab
                    text: i18n("Devices")

                    KeyNavigation.up: fullRep.KeyNavigation.up
                }

                PC3.TabButton {
                    id: streamsTab
                    text: i18n("Applications")

                    KeyNavigation.up: fullRep.KeyNavigation.up
                }
            }

            PC3.ToolButton {
                id: globalMuteCheckbox

                visible: true// !(plasmoid.containmentDisplayHints & PlasmaCore.Types.ContainmentDrawsPlasmoidHeading)

                icon.name: "audio-volume-muted"
                onClicked: {
                    GlobalService.globalMute()
                }
                checked: globalMute

                Accessible.name: i18n("Force mute all playback devices")
                PC3.ToolTip {
                    text: i18n("Force mute all playback devices")
                }
            }

            PC3.ToolButton {
                visible: true // !(plasmoid.containmentDisplayHints & PlasmaCore.Types.ContainmentDrawsPlasmoidHeading)

                icon.name: "configure"
                onClicked:  KCM.KCMLauncher.openSystemSettings("kcm_pulseaudio")

                Accessible.name: i18n("Configure Audio Devices")
                PC3.ToolTip {
                    text: i18n("Configure Audio Devices")
                }
            }
        }

        VolumeComponents.HorizontalStackView {
            id: contentView
            initialItem: volumePage.currentTab === "streams" ? streamsView : devicesView
            movementTransitionsEnabled: currentItem !== null
            Layout.fillHeight: true
            Layout.fillWidth: true
            TwoPartView {
                id: devicesView
                upperModel: paSinkFilterModel
                upperType: "sink"
                lowerModel: paSourceFilterModel
                lowerType: "source"
                iconName: "audio-volume-muted"
                placeholderText: volumePage.noDevicePlaceholderMessage
                upperDelegate: VolumeComponents.DeviceListItem {
                    width: ListView.view.width
                    type: devicesView.upperType
                }
                lowerDelegate: VolumeComponents.DeviceListItem {
                    width: ListView.view.width
                    type: devicesView.lowerType
                }
            }
            // NOTE: Don't unload this while dragging and dropping a stream
            // to a device or else the D&D operation will be cancelled.
            TwoPartView {
                id: streamsView
                upperModel: paSinkInputFilterModel
                upperType: "sink-input"
                lowerModel: paSourceOutputFilterModel
                lowerType: "source-output"
                iconName: "edit-none"
                placeholderText: i18n("No applications playing or recording audio")
                upperDelegate: VolumeComponents.StreamListItem {
                    width: ListView.view.width
                    type: streamsView.upperType
                    devicesModel: paSinkFilterModel
                }
                lowerDelegate: VolumeComponents.StreamListItem {
                    width: ListView.view.width
                    type: streamsView.lowerType
                    devicesModel: paSourceFilterModel
                }
            }
            Connections {
                target: tabBar
                function onCurrentIndexChanged() {
                    if (tabBar.currentItem === devicesTab) {
                        contentView.reverseTransitions = false
                        contentView.replace(devicesView)
                    } else if (tabBar.currentItem === streamsTab) {
                        contentView.reverseTransitions = true
                        contentView.replace(streamsView)
                    }
                }
            }
        }

        component TwoPartView : PC3.ScrollView {
            id: scrollView
            required property PulseObjectFilterModel upperModel
            required property string upperType
            required property Component upperDelegate
            required property PulseObjectFilterModel lowerModel
            required property string lowerType
            required property Component lowerDelegate
            property string iconName: ""
            property string placeholderText: ""

             // HACK: workaround for https://bugreports.qt.io/browse/QTBUG-83890
            PC3.ScrollBar.horizontal.policy: PC3.ScrollBar.AlwaysOff

            Loader {
                //parent: scrollView
                anchors.fill: parent
               // width: parent.width -  Kirigami.Units.gridUnit * 4
                active: visible
                visible: scrollView.placeholderText.length > 0 && !upperSection.visible && !lowerSection.visible
                sourceComponent: PlasmaExtras.PlaceholderMessage {
                    iconName: scrollView.iconName
                    text: scrollView.placeholderText
                }
            }
            contentItem: Flickable {
                contentHeight: layout.implicitHeight
                clip: true

                property ListView upperListView: upperSection.visible ? upperSection : lowerSection
                property ListView lowerListView: lowerSection.visible ? lowerSection : upperSection

                ColumnLayout {
                    id: layout
                    anchors.fill: parent
                    spacing: 0
                    ListView {
                        id: upperSection
                        visible: count //&& !fullRep.hiddenTypes.includes(scrollView.upperType)
                        interactive: false
                        Layout.fillWidth: true
                        implicitHeight: contentHeight
                        model: scrollView.upperModel
                        delegate: scrollView.upperDelegate
                        focus: visible

                        Keys.onDownPressed: event => {
                            if (currentIndex < count - 1) {
                                incrementCurrentIndex();
                                currentItem.forceActiveFocus();
                            } else if (lowerSection.visible) {
                                lowerSection.currentIndex = 0;
                                lowerSection.currentItem.forceActiveFocus();
                            } else {
                                raiseMaximumVolumeCheckbox.forceActiveFocus(Qt.TabFocusReason);
                            }
                            event.accepted = true;
                        }
                        Keys.onUpPressed: event => {
                            if (currentIndex > 0) {
                                decrementCurrentIndex();
                                currentItem.forceActiveFocus();
                            } else {
                                tabBar.currentItem.forceActiveFocus(Qt.BacktabFocusReason);
                            }
                            event.accepted = true;
                        }
                    }
                    KSvg.SvgItem {
                        imagePath: "widgets/line"
                        elementId: "horizontal-line"
                        Layout.fillWidth: true
                        Layout.leftMargin: Kirigami.Units.smallSpacing * 2
                        Layout.rightMargin: Layout.leftMargin
                        Layout.topMargin: Kirigami.Units.smallSpacing
                        visible: upperSection.visible && lowerSection.visible
                    }
                    ListView {
                        id: lowerSection
                        visible: count //&& !fullRep.hiddenTypes.includes(scrollView.lowerType)
                        interactive: false
                        Layout.fillWidth: true
                        implicitHeight: contentHeight
                        model: scrollView.lowerModel
                        delegate: scrollView.lowerDelegate
                        focus: visible && !upperSection.visible

                        Keys.onDownPressed: event => {
                            if (currentIndex < count - 1) {
                                incrementCurrentIndex();
                                currentItem.forceActiveFocus();
                            } else {
                                raiseMaximumVolumeCheckbox.forceActiveFocus(Qt.TabFocusReason);
                            }
                            event.accepted = true;
                        }
                        Keys.onUpPressed: event => {
                            if (currentIndex > 0) {
                                decrementCurrentIndex();
                                currentItem.forceActiveFocus();
                            } else if (upperSection.visible) {
                                upperSection.currentIndex = upperSection.count - 1;
                                upperSection.currentItem.forceActiveFocus();
                            } else {
                                tabBar.currentItem.forceActiveFocus(Qt.BacktabFocusReason);
                            }
                            event.accepted = true;
                        }
                    }
                }
            }
        }
    }

}