import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15
//import QtGraphicalEffects 1.0

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
Item {
    id: compactRep
    
    RowLayout {
        anchors.fill: parent
        
        Kirigami.Icon {
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: root.mainIconName
            smooth: true
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.expanded = !root.expanded
                }
            }
        }
    }
}
