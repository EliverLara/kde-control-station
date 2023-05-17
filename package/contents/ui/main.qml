import QtQuick 2.0
import QtQuick.Controls 2.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.1 as PlasmaCore
import "js/colorType.js" as ColorType

Item {
    id: root
    
    clip: true

    // PROPERTIES
    property bool enableTransparency: plasmoid.configuration.transparency
    property var animationDuration: PlasmaCore.Units.veryShortDuration
    property bool playVolumeFeedback: plasmoid.configuration.playVolumeFeedback

    property var scale: plasmoid.configuration.scale * PlasmaCore.Units.devicePixelRatio / 100
    property int fullRepWidth: 420 * scale
    property int fullRepHeight: 380 * scale
    property int sectionHeight: 180 * scale

    property int largeSpacing: 12 * scale
    property int mediumSpacing: 8 * scale
    property int smallSpacing: 6 * scale

    property int buttonMargin: 4 * scale
    property int buttonHeight: 48 * scale

    property int largeFontSize: 15 * scale
    property int mediumFontSize: 12 * scale
    property int smallFontSize: 7 * scale

    property int itemSpacing: 8

    // COlors variables
    property color themeBgColor: PlasmaCore.Theme.backgroundColor
    property color themeHighlightColor: PlasmaCore.Theme.highlightColor
    property bool isDarkTheme: ColorType.isDark(themeBgColor)
    
    // Main Icon
    property string mainIconName: plasmoid.configuration.mainIconName
    property string mainIconHeight: plasmoid.configuration.mainIconHeight
    
    // Components
    property bool showKDEConnect: plasmoid.configuration.showKDEConnect
    property bool showNightColor: plasmoid.configuration.showNightColor
    property bool showColorSwitcher: plasmoid.configuration.showColorSwitcher
    property bool showDnd: plasmoid.configuration.showDnd
    property bool showVolume: plasmoid.configuration.showVolume
    property bool showBrightness: plasmoid.configuration.showBrightness
    property bool showMediaPlayer: plasmoid.configuration.showMediaPlayer
    property bool showCmd1: plasmoid.configuration.showCmd1
    property bool showCmd2: plasmoid.configuration.showCmd2
    property bool showPercentage: plasmoid.configuration.showPercentage
    
    property string cmdRun1: plasmoid.configuration.cmdRun1
    property string cmdTitle1: plasmoid.configuration.cmdTitle1
    property string cmdIcon1: plasmoid.configuration.cmdIcon1
    property string cmdRun2: plasmoid.configuration.cmdRun2
    property string cmdTitle2: plasmoid.configuration.cmdTitle2
    property string cmdIcon2: plasmoid.configuration.cmdIcon2

    readonly property bool inPanel: (Plasmoid.location === PlasmaCore.Types.TopEdge
        || Plasmoid.location === PlasmaCore.Types.RightEdge
        || Plasmoid.location === PlasmaCore.Types.BottomEdge
        || Plasmoid.location === PlasmaCore.Types.LeftEdge)

    PlasmaCore.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: sources
        function performOperation(what) {
            var service = serviceForSource("PowerDevil")
            var operation = service.operationDescription(what)
            service.startOperationCall(operation)
        }
    }

    property QtObject batteries: PlasmaCore.SortFilterModel {
        id: batteries
        filterRole: "Is Power Supply"
        sortOrder: Qt.DescendingOrder
        sourceModel: PlasmaCore.SortFilterModel {
            sortRole: "Pretty Name"
            sortOrder: Qt.AscendingOrder
            sortCaseSensitivity: Qt.CaseInsensitive
            sourceModel: PlasmaCore.DataModel {
                dataSource: pmSource
                sourceFilter: "Battery[0-9]+"
            }
        }
    }

    property var battery: pmSource.data["Battery"]
    readonly property int remainingTime: Number(pmSource.data["Battery"]["Smoothed Remaining msec"])
    
    Plasmoid.switchHeight: fullRepWidth
    Plasmoid.switchWidth: fullRepWidth
    Plasmoid.preferredRepresentation: inPanel ? plasmoid.compactRepresentation : plasmoid.fullRepresentation
    Plasmoid.fullRepresentation: FullRepresentation {
        battery: root.battery
        remainingTime: root.remainingTime
    }
    Plasmoid.compactRepresentation: CompactRepresentation {}
}
