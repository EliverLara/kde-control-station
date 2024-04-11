import QtQuick 2.15
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.15
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.ksvg as KSvg
import "../lib" as Lib

Lib.Card {
    id: toggled

    property alias model: listview.model

    property alias delegate: listview.delegate

    property string sectionTitle

 //   property alias extraHeaderItems: listview.header.headerActions.children

    function toggleSection() {
        if (!toggled.visible) {
            wrapper.visible = false;
            toggled.visible = true;
        } else {
            wrapper.visible = true;
            toggled.visible = false;
        }
    }

    anchors.fill: parent
    z: 999
    visible: false
    scale: visible ? 1.0 : 0.1

    Behavior on scale { 
        NumberAnimation  { duration: 200 ; easing.type: Easing.InOutQuad  } 
    }
    Item {
        anchors.fill: parent
        anchors.margins: root.smallSpacing

        ListView {
            id: listview
            anchors.fill: parent

            ScrollBar.vertical: ScrollBar {
            }

            header: ColumnLayout {
                width: parent.width
                spacing: root.smallSpacing

                RowLayout {
                    id:headerActions
                    height: implicitHeight + root.smallSpacing

                    ToolButton {
                        Layout.preferredHeight: root.largeFontSize * 2.5
                        icon.name: "arrow-left"
                        MouseArea {
                            
                            anchors.fill: parent
                            
                            onClicked: {
                                toggled.toggleSection();
                            }
                        }
                    }

                    PlasmaComponents.Label {
                        text: toggled.sectionTitle
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
                    Layout.fillHeight: true
                }

            }

        }

    }

}
