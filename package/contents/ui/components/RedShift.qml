import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.private.nightcolorcontrol as Redshift

import "../lib" as Lib
import "../js/funcs.js" as Funcs


Lib.CardButton {
    // NIGHT COLOUR CONTROL
    visible: root.showNightColor
    property var monitor: redMonitor
    property var inhibitor: inhibitor
    Redshift.Monitor {
        id: redMonitor
    }
    Redshift.Inhibitor {
        id: inhibitor
    }
    Layout.fillWidth: true
    Layout.fillHeight: true
    title: i18n("Night Color")
    PlasmaCore.IconItem {
        anchors.fill: parent
        source: monitor.running ? "redshift-status-on" : "redshift-status-off"
    }
    onClicked: {
        Funcs.toggleRedshiftInhibition();
    }
}