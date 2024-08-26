import QtQuick 2.15
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.15
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.networkmanagement as PlasmaNM
import "../lib" as Lib
import org.kde.plasma.private.sessions as Sessions
import org.kde.kirigami as Kirigami

PageTemplate {
    id: systemSessionActionsPage

    sectionTitle: i18n("Session Actions")

    Sessions.SessionManagement {
        id: sm
    }

     ListModel {
        id: actionsModel

        ListElement {
            name: "Lock Screen"
            icon: "system-lock-screen"
            action: () => sm.lock()
        }
        ListElement {
            name: "Log Out"
            icon: "system-log-out"
            action: () => sm.requestLogout(1)
        }
        ListElement {
            name: "Restart"
            icon: "system-reboot"
            action: () => sm.requestReboot(1)
        }
        ListElement {
            name: "Shutdown"
            icon: "system-shutdown"
            action: () => sm.requestShutdown(1)
        }
        ListElement {
            name: "Suspend"
            icon: "system-suspend"
            action: () => sm.suspend()
        }
    }


    GridLayout {
        id: buttonsColumn
        anchors.fill: parent
        anchors.margins: root.smallSpacing

        columns: 1

        property int columnImplicitWidth: children[0].width + columnSpacing
        property int implicitW: repeater.count * columnImplicitWidth

        Repeater {
            id: repeater
            model: actionsModel
            Lib.CardButton {

                visible: root.showColorSwitcher
                Layout.fillWidth: true
                Layout.preferredHeight: root.sectionHeight / 3
                title: name
                Kirigami.Icon {
                    anchors.fill: parent
                    source: icon
                    selected: false
                }

                onClicked: action()
            }
        }
    }
}
