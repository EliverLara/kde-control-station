import QtQuick 2.15
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.15
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.ksvg as KSvg
import "../lib" as Lib
import org.kde.plasma.extras as PlasmaExtras


Lib.Card {
    id: page

    // PROPERTIES
    Layout.preferredWidth: root.fullRepWidth
    Layout.preferredHeight: wrapper.implicitHeight
    Layout.minimumWidth: Layout.preferredWidth
    Layout.maximumWidth: Layout.preferredWidth
    Layout.minimumHeight: Layout.preferredHeight
    Layout.maximumHeight: Layout.preferredHeight
    clip: true

    property string sectionTitle

    default property alias content: dataContainer.data

    function toggleSection() {
        if (!page.visible) {
            wrapper.visible = false;
            page.visible = true;
        } else {
            wrapper.visible = true;
            page.visible = false;
        }
    }

    anchors.fill: parent
    z: 999
    visible: false
    scale: visible ? 1.0 : 0.1

    Behavior on scale { 
        NumberAnimation  { duration: 200 ; easing.type: Easing.InOutQuad  } 
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: root.smallSpacing
        anchors.margins: 5

        RowLayout {
            id:headerActions

            Layout.fillWidth: true

            ToolButton {
                Layout.preferredHeight: root.largeFontSize * 2.5
                icon.name: "arrow-left"
                MouseArea {
                    
                    anchors.fill: parent
                    
                    onClicked: {
                        page.toggleSection();
                    }
                }
            }

            PlasmaComponents.Label {
                text: page.sectionTitle
                font.pixelSize: root.largeFontSize * 1.2
                Layout.fillWidth: true
            }

        }

        KSvg.SvgItem {
            id: separatorLine

            z: 4
            elementId: "horizontal-line"
            Layout.fillWidth: true
            Layout.preferredHeight: root.scale

            svg: KSvg.Svg {
                imagePath: "widgets/line"
            }

        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            id: dataContainer
        }

    }

}
