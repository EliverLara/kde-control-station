import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../lib" as Lib
import "../js/funcs.js" as Funcs
import org.kde.notificationmanager as NotificationManager
import org.kde.kirigami as Kirigami

Lib.CardButton {
    visible: root.showDnd
    Layout.columnSpan: 2
    Layout.fillWidth: true
    Layout.fillHeight: true
    title: i18n("Do Not Disturb")
        
    // NOTIFICATION MANAGER
    property var notificationSettings: notificationSettings
    NotificationManager.Settings {
        id: notificationSettings
    }
    
    // Enables "Do Not Disturb" on click
    onClicked: {
        Funcs.toggleDnd();
    }
    
    Lib.Icon {
        id: dndIcon
        anchors.fill: parent
        source: {
            return (Funcs.checkInhibition() ? "notifications-disabled" : "notifications");
        }
        selected: Funcs.checkInhibition()
    }
}