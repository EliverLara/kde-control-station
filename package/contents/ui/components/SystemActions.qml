import QtQuick 2.0
import QtQuick.Layouts 1.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents2
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
import org.kde.kcoreaddons 1.0 as KCoreAddons
import org.kde.plasma.workspace.components 2.0
import QtGraphicalEffects 1.0

import "../lib" as Lib

Lib.Card {
    id: sysActions

   Layout.preferredWidth: root.sectionHeight/3.5
   Layout.preferredHeight: root.sectionHeight/3.5

   property bool showToolTip: false
 
    PlasmaComponents.ToolTip {
        text: i18n("Power Off")
    }

    Image {
        id: powerImage
        source: "../icons/feather/power.svg"
        width: 20 * PlasmaCore.Units.devicePixelRatio
        height: width
        anchors.centerIn: parent

        ColorOverlay {
            visible: true
            anchors.fill: powerImage
            source: powerImage
            color: theme.textColor
        }
    }

    PlasmaComponents.ToolTip {
        parent: sysActions
        visible: showToolTip
        text: i18n("Power Off")
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: {
            pmSource.performOperation("requestShutDown")
        }
        onEntered: showToolTip = true
        onExited: showToolTip = false
    }
}



