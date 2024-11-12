import QtQuick 2.15
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.15
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.extras as PlasmaExtras

import org.kde.kirigami 2 as Kirigami


import org.kde.plasma.private.mediacontroller
import org.kde.plasma.private.mpris as Mpris


import "../lib" as Lib
import "components/mediaPlayer" as MediaComponents
PageTemplate {
    id: mediaPlayerPage

    sectionTitle: i18n("Media Player")
    customHeader: true

    readonly property int volumePercentStep: config.volumeStep

    property alias mpris2Model: mpris2Model
    property alias playerList: playerList

    // BEGIN model properties
    readonly property string track: mpris2Model.currentPlayer?.track ?? ""
    readonly property string artist: mpris2Model.currentPlayer?.artist ?? ""
    readonly property string album: mpris2Model.currentPlayer?.album ?? ""
    readonly property string albumArt: mpris2Model.currentPlayer?.artUrl ?? ""
    readonly property string identity: mpris2Model.currentPlayer?.identity ?? ""
    readonly property bool canControl: mpris2Model.currentPlayer?.canControl ?? false
    readonly property bool canGoPrevious: mpris2Model.currentPlayer?.canGoPrevious ?? false
    readonly property bool canGoNext: mpris2Model.currentPlayer?.canGoNext ?? false
    readonly property bool canPlay: mpris2Model.currentPlayer?.canPlay ?? false
    readonly property bool canPause: mpris2Model.currentPlayer?.canPause ?? false
    readonly property bool canStop: mpris2Model.currentPlayer?.canStop ?? false
    readonly property int playbackStatus: mpris2Model.currentPlayer?.playbackStatus ?? 0
    readonly property bool isPlaying: mediaPlayerPage.playbackStatus === Mpris.PlaybackStatus.Playing
    readonly property bool canRaise: mpris2Model.currentPlayer?.canRaise ?? false
    readonly property bool canQuit: mpris2Model.currentPlayer?.canQuit ?? false
    readonly property int shuffle: mpris2Model.currentPlayer?.shuffle ?? 0
    readonly property int loopStatus: mpris2Model.currentPlayer?.loopStatus ?? 0


    Item {
        anchors.fill: parent

        RowLayout {
            id: header
            anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
             }
            z: mediaPlayerWidget.z+1
            ToolButton {
                Layout.preferredHeight: root.largeFontSize * 2.5
                icon.name: "arrow-left"
                icon.color: mediaPlayerWidget.iconColor
                MouseArea {
                    
                    anchors.fill: parent
                    
                    onClicked: {
                        mediaPlayerPage.toggleSection();
                    }
                }
            }

            PC3.TabBar {
                id: playerSelector
                objectName: "playerSelector"
                Layout.fillWidth: true
                implicitHeight: contentHeight
                currentIndex: playerSelector.count, mpris2Model.currentIndex
                position: PC3.TabBar.Header

                Repeater {
                    id: playerList
                    model: mpris2Model
                    delegate: PC3.TabButton {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        implicitWidth: 1 // HACK: suppress binding loop warnings
                        readonly property QtObject m: model
                        display: PC3.AbstractButton.IconOnly
                        icon.name: model.iconName
                        icon.height: Kirigami.Units.iconSizes.smallMedium
                        icon.color: "red"
                        text: model.identity
                        // Keep the delegate centered by offsetting the padding removed in the parent
                        bottomPadding: verticalPadding 
                        topPadding: verticalPadding

                        Accessible.onPressAction: clicked()
                       // KeyNavigation.down: seekSlider.visible ? seekSlider : seekSlider.KeyNavigation.down

                        onClicked: {
                            mpris2Model.currentIndex = index;
                        }

                        PC3.ToolTip.text: text
                        PC3.ToolTip.delay: Kirigami.Units.toolTipDelay
                        PC3.ToolTip.visible: hovered || (activeFocus && (focusReason === Qt.TabFocusReason || focusReason === Qt.BacktabFocusReason))
                    }
                }
            }

        }
        MediaComponents.ExpandedRepresentation {
            id: mediaPlayerWidget
            anchors.fill: parent
        }
    }
    
    function previous() {
        mpris2Model.currentPlayer.Previous();
    }
    function next() {
        mpris2Model.currentPlayer.Next();
    }
    function play() {
        mpris2Model.currentPlayer.Play();
    }
    function pause() {
        mpris2Model.currentPlayer.Pause();
    }
    function togglePlaying() {
        mpris2Model.currentPlayer.PlayPause();
    }
    function stop() {
        mpris2Model.currentPlayer.Stop();
    }
    function quit() {
        mpris2Model.currentPlayer.Quit();
    }
    function raise() {
        mpris2Model.currentPlayer.Raise();
    }

    Mpris.Mpris2Model {
        id: mpris2Model
    }

    GlobalConfig {
        id: config
    }
}