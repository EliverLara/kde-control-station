import QtQuick 2.15
import QtQuick.Layouts 1.15
//import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami
import Qt5Compat.GraphicalEffects

import org.kde.plasma.private.mediacontroller 1.0
import org.kde.plasma.private.mpris as Mpris

import "../lib" as Lib

Lib.Card {
    id: mediaPlayer
    visible: root.showMediaPlayer
    Layout.fillWidth: true
    Layout.preferredHeight: root.sectionHeight/2

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
    readonly property bool isPlaying: playbackStatus === Mpris.PlaybackStatus.Playing
    readonly property bool canRaise: mpris2Model.currentPlayer?.canRaise ?? false
    readonly property bool canQuit: mpris2Model.currentPlayer?.canQuit ?? false
    readonly property int shuffle: mpris2Model.currentPlayer?.shuffle ?? 0
    readonly property int loopStatus: mpris2Model.currentPlayer?.loopStatus ?? 0

    Mpris.Mpris2Model {
        id: mpris2Model
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


    RowLayout {
        anchors.fill: parent
        anchors.margins: root.largeSpacing

        Image {
            id: audioThumb
            fillMode: Image.PreserveAspectCrop
            source: mediaPlayer.albumArt || "../../assets/music.svg"
            Layout.fillHeight: true
            Layout.preferredWidth: height
            enabled: track || (mediaPlayer.playbackStatus > Mpris.PlaybackStatus.Stopped) ? true : false

            ColorOverlay {
                visible: !mediaPlayer.albumArt && audioThumb.enabled
                anchors.fill: audioThumb
                source: audioThumb
                color: Kirigami.Theme.textColor
            }
        }
        ColumnLayout {
            id: mediaNameWrapper
            Layout.margins: root.smallSpacing
            Layout.fillHeight: true
            spacing: 0

            PlasmaComponents.Label {
                id: audioTitle
                Layout.fillWidth: true
                font.capitalization: Font.Capitalize
                font.weight: Font.Bold
                font.pixelSize: root.largeFontSize
                enabled: track || (mediaPlayer.playbackStatus > Mpris.PlaybackStatus.Stopped) ? true : false
                //horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                text: track ? track : (mediaPlayer.playbackStatus > Mpris.PlaybackStatus.Stopped) ? i18n("No title") : i18n("No media playing")
            }
            PlasmaComponents.Label {
                id: audioArtist
                Layout.fillWidth: true
                font.pixelSize: root.mediumFontSize
               // horizontalAlignment: Text.AlignHCenter
                text: artist
            }
        }
        RowLayout {
            id: audioControls
            Layout.alignment: Qt.AlignRight


            PlasmaComponents.ToolButton {
                id: previousButton
                Layout.preferredHeight: mediaNameWrapper.implicitHeight
                Layout.preferredWidth: height
                icon.name: "media-skip-backward"
                enabled: mediaPlayer.canGoPrevious
                onClicked: {
                    //seekSlider.value = 0    // Let the media start from beginning. Bug 362473
                    mediaPlayer.previous()
                }
            }

            PlasmaComponents.ToolButton { // Pause/Play
                id: playPauseButton

                Layout.preferredHeight: mediaNameWrapper.implicitHeight
                Layout.preferredWidth: height

                Layout.alignment: Qt.AlignVCenter
                enabled: mediaPlayer.isPlaying ? mediaPlayer.canPause : mediaPlayer.canPlay
                icon.name: mediaPlayer.isPlaying ? "media-playback-pause" : "media-playback-start"

                onClicked: mediaPlayer.togglePlaying()
            }


            PlasmaComponents.ToolButton {
                id: nextButton
                Layout.preferredHeight: mediaNameWrapper.implicitHeight
                Layout.preferredWidth: height
                icon.name: "media-skip-forward"
                enabled: mediaPlayer.canGoNext
                onClicked: {
                    //seekSlider.value = 0    // Let the media start from beginning. Bug 362473
                    mediaPlayer.next()
                }
            }
        }
    }
}
