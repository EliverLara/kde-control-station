import QtQuick 2.15
import QtQml 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

Rectangle {
    id: rectangle
    color: "transparent"

    /*******
     Container means that is used to group widgets(sections) such as QuickToggleButtons and SectionScreenControls,
     and it shoud not display a shadow nor background color 
    ********/
    property bool isContainer: false

    /******
     We need to gain space to display the shadow so we reduce top and bottom margins to avoid cut elements
     in small widgets such as UserAvatar 
    *******/
    property bool smallMargins: false

    property var margins: shadowContainer.margins
    default property alias content: dataContainer.data
    radius: 12

    Item {
        id: shadowContainer
        visible: !isContainer
        
        anchors.fill: parent
        anchors.margins: 0
        layer.enabled: true

        opacity: 0.2 // This controls the opcity of the shadow
        clip: true

        /*
        * This is the real widget where the the shadow is drawn around, we applied some margins
        * to separate it from it's parent(container) so the shadow could be displayed
        */
        Rectangle {
            id: shadowWidget
            anchors.fill: parent
            anchors.margins: 6
            color: root.themeBgColor
            radius: 12
                
        }
        DropShadow {
            anchors.fill: shadowWidget
            source: shadowWidget
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 2
            radius: 12
            samples: 25
            color: "black"
        }
    }

    Rectangle {
        id: cardBg; 
        color: root.enableTransparency ? 
                Qt.rgba(root.themeBgColor.r, root.themeBgColor.g, root.themeBgColor.b, root.transparencyLevel/100)
                : root.themeBgColor

        border.color: root.showBorders ? (root.isDarkTheme ? Qt.lighter(root.themeBgColor, 2.0) : Qt.darker(root.themeBgColor, 1.3)) : "transparent"
        anchors.centerIn: shadowContainer
        visible: !isContainer
        width: shadowWidget.width
        height: shadowWidget.height
        radius: 12
        z: -1
    }

    Item {
        id: dataContainer
        anchors.fill: parent
        anchors.topMargin: isContainer ? -1 : smallMargins ? 2 : 5
        anchors.bottomMargin: isContainer ? -1 : smallMargins ? 2 : 5
        anchors.leftMargin: isContainer ? -1 : 5
        anchors.rightMargin: isContainer ? -1 : 5
    }
}