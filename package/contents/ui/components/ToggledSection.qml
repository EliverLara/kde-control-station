import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import "../lib" as Lib

Lib.Card {
    id: toggled

    property alias model: listview.model

    property alias delegate: listview.delegate

    property string text

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
                    height: implicitHeight + root.smallSpacing

                    PlasmaComponents.ToolButton {
                        Layout.preferredHeight: root.largeFontSize * 2.5
                        iconSource: "arrow-left"
                        onClicked: {
                            toggled.toggleSection();
                        }
                    }

                    PlasmaComponents.Label {
                        
                        text: toggled.text
                        font.pixelSize: root.largeFontSize * 1.2
                        Layout.fillWidth: true
                    }

                }

                PlasmaCore.SvgItem {
                    id: separatorLine

                    z: 4
                    elementId: "horizontal-line"
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.scale

                    svg: PlasmaCore.Svg {
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
