import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents2
import org.kde.plasma.components as PlasmaComponents
import org.kde.kquickcontrolsaddons as KQuickAddons
import org.kde.coreaddons as KCoreAddons
import org.kde.plasma.workspace.components 2.0
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami

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
        width: 20 * 1
        height: width
        anchors.centerIn: parent

        ColorOverlay {
            visible: true
            anchors.fill: powerImage
            source: powerImage
            color: Kirigami.Theme.textColor
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
            systemSessionActionsPage.toggleSection()
        }
        onEntered: showToolTip = true
        onExited: showToolTip = false
    }
}



