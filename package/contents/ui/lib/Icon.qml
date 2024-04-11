import QtQuick 2.15
import QtQuick.Layouts 1.15
//import QtGraphicalEffects 1.15
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

Item
{
    property alias sourceColor:rect.color
    property alias source: icon.source

    Rectangle {
        id: rect
        radius: width/2
        color: Kirigami.Theme.highlightColor
        anchors.fill: parent
        

        Kirigami.Icon {
            id: icon
            anchors.fill: parent
            anchors.margins: root.smallSpacing
            anchors.centerIn: parent
           // status: Kirigami.Icon.Selected
        }
    }
}
