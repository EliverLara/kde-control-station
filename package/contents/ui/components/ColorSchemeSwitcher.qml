import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.0

import org.kde.plasma.plasmoid
//import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami 

import "../lib" as Lib


Lib.CardButton {
    id: colorSchemeSwitcher

    visible: root.showColorSwitcher
    Layout.fillHeight: true
    Layout.fillWidth: true
    title: i18n("Dark Theme")
    Lib.Icon {
        anchors.fill: parent
        source: root.isDarkTheme ? "brightness-high" : "brightness-low"
        selected: root.isDarkTheme
    }

    onClicked: {
        executable.swapColorScheme();
        root.isDarkTheme = !root.isDarkTheme
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: { 
            disconnectSource(sourceName)
        }
        
        function exec(cmd) {
            connectSource(cmd)
        }

        function swapColorScheme() {
            var colorSchemeName = root.isDarkTheme ? Plasmoid.configuration.lightTheme : Plasmoid.configuration.darkTheme
            exec("plasma-apply-colorscheme " + colorSchemeName)
        }
    }
}
