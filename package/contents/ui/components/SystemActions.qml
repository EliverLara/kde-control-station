import QtQuick 2.0
import QtQuick.Layouts 1.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents2
import org.kde.plasma.components 3.0 as PlasmaComponents

import "../lib" as Lib

Lib.Card {
    id: avatar

   Layout.fillWidth: true
   Layout.preferredHeight: root.sectionHeight/3.5
 
    PlasmaCore.DataSource {
        id: pmEngine
        engine: "powermanagement"
        connectedSources: ["PowerDevil", "Sleep States"]
        function performOperation(what) {
            var service = serviceForSource("PowerDevil")
            var operation = service.operationDescription(what)
            service.startOperationCall(operation)
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: root.mediumSpacing
        
        clip: true

        PlasmaComponents.RoundButton {
            id: settingsButton
            visible: true
            flat: true
            height: parent.height
            width: height

            anchors.left: parent.left

            PlasmaComponents.ToolTip {
                text: i18n("Settings")
            }

            Image {
                id: settingsImage
                
                anchors.centerIn: parent

                source: "../icons/feather/settings.svg"
                width: 20 * PlasmaCore.Units.devicePixelRatio
                height: width
            }
            onClicked: {
                KQuickAddons.KCMShell.openSystemSettings("kcm_quick")
            }
        }

        Rectangle {
            width: 2
            height: settingsButton.height / 2
            color: "#f00"
            anchors.centerIn: parent
        }

        PlasmaComponents.RoundButton {
            id: powerButton
            visible: true
            flat: true
            height: parent.height
            width: height

            anchors.right: parent.right

            PlasmaComponents.ToolTip {
                text: i18n("Power Off")
            }

            Image {
                id: powerImage
                source: "../icons/feather/power.svg"
                width: 20 * PlasmaCore.Units.devicePixelRatio
                height: width
                
                anchors.centerIn: parent
            
            }
            onClicked: {
                pmEngine.performOperation("requestShutDown")
            }
        }
    }

}



