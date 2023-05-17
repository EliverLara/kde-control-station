import QtQuick 2.0
import QtQml 2.0
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Rectangle {
    color: root.enableTransparency ? 
           Qt.rgba(root.themeBgColor.r, root.themeBgColor.g, root.themeBgColor.b, 0.4)
           : root.themeBgColor

    border.color: root.isDarkTheme ? Qt.lighter(root.themeBgColor, 2.0) : Qt.darker(root.themeBgColor, 1.3)

    property var margins: rect.margins
    default property alias content: dataContainer.data
    radius: 12

    Item {
        id: rect
        anchors.fill: parent
        
        anchors.margins: 0

        Item {
            id: dataContainer
            anchors.fill: parent
        }
    }
}
