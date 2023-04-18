import QtQuick 2.0
import QtQml 2.0
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Rectangle {
    color: "#161925"
   // property alias prefix: rect.prefix
    property var margins: rect.margins
    default property alias content: dataContainer.data
    radius: 12

    Rectangle {
        id: rect 
        color:"#161925"
        radius: 12
        anchors.fill: parent
        
        anchors.margins: 0
        
        // anchors.topMargin: rect.margins.top * root.scale
        // anchors.leftMargin: rect.margins.left * root.scale
        // anchors.rightMargin: rect.margins.right * root.scale
        // anchors.bottomMargin: rect.margins.bottom * root.scale

        Item {
            id: dataContainer
            anchors.fill: parent
        }

    }

    // PlasmaCore.FrameSvgItem {
    //     id: rect

    //     imagePath: root.enableTransparency ? "translucent/dialogs/background" : "opaque/dialogs/background"
    //     clip: true
    //     anchors.fill: parent
    //     anchors.topMargin: rect.margins.top * root.scale
    //     anchors.leftMargin: rect.margins.left * root.scale
    //     anchors.rightMargin: rect.margins.right * root.scale
    //     anchors.bottomMargin: rect.margins.bottom * root.scale

    //     Item {
    //         id: dataContainer
    //         anchors.fill: parent
    //     }
    // }
}
