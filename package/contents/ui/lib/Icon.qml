import QtQuick 2.15
import QtQuick.Layouts 1.15
//import QtGraphicalEffects 1.15
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

Item
{
    property alias sourceColor:rect.color
    property alias source: icon.source
    property alias selected: icon.selected

    Rectangle {
        id: rect
        radius: width/2
        color: icon.selected ? Kirigami.Theme.highlightColor : root.disabledBgColor
        anchors.fill: parent
        

        Kirigami.Icon {
            id: icon
            anchors.fill: parent
            anchors.margins: root.smallSpacing
            anchors.centerIn: parent
            selected: false
        }
    }
}
