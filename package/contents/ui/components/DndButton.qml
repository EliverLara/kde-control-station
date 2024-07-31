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
    
    Component.onCompleted: updateIcon()
    
    // NOTIFICATION MANAGER
    property var notificationSettings: notificationSettings
    NotificationManager.Settings {
        id: notificationSettings
    }
    
    // Enables "Do Not Disturb" on click
    onClicked: {
        var d= new Date();
        d.setYear(d.getFullYear()+1)
        
        // Checking if do not disturb is already enabled 
        if (Funcs.checkInhibition()) {
            Funcs.revokeInhibitions()
        } else {
            notificationSettings.notificationsInhibitedUntil = d
            notificationSettings.save()
        }
        updateIcon()
    }
    
    // Updates icon
    function updateIcon() {
        if (Funcs.checkInhibition()) {
            dndIcon.source = "notifications-disabled"
            dndIcon.sourceColor =  root.themeHighlightColor
        } else {
            dndIcon.source = "notifications"
            dndIcon.sourceColor = Kirigami.Theme.disabledTextColor
        }
    }
    
    Lib.Icon {
        id: dndIcon
        anchors.fill: parent
    }
}