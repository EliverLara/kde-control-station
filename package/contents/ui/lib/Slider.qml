import QtQuick 2.0
import QtQuick.Layouts 1.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents2
import org.kde.plasma.components 3.0 as PlasmaComponents
import QtGraphicalEffects 1.0

Card {
    id: sliderComp
    signal moved
    signal clicked

    property alias title: title.text
    property alias secondaryTitle: secondaryTitle.text
    property alias value: slider.value
    property bool useIconButton: false
    property string source


    property int from: 0
    property int to: 100


    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.largeSpacing
        clip: true

        RowLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: root.smallSpacing

            PlasmaComponents.Label {
                id: title
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
                font.pixelSize: root.largeFontSize
                font.weight: Font.Bold
                font.capitalization: Font.Capitalize
            }

            PlasmaComponents.Label {
                id: secondaryTitle
                visible: root.showPercentage
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                font.pixelSize: root.largeFontSize
                font.weight: Font.Bold
                font.capitalization: Font.Capitalize
                horizontalAlignment: Text.AlignRight
            }


        }

        // RowLayout {
        //     Layout.fillHeight: true
        //     Layout.fillWidth: true
        //     spacing: root.smallSpacing

        //     PlasmaCore.IconItem {
        //         id: icono
        //         source: sliderComp.source
        //         visible: !sliderComp.useIconButton
        //         Layout.preferredHeight: root.largeFontSize*2
        //         Layout.preferredWidth: Layout.preferredHeight
        //     }
            
        //     PlasmaComponents2.ToolButton {
        //         id: iconButton2
        //         visible: sliderComp.useIconButton
        //         iconSource: sliderComp.source
        //         Layout.preferredHeight: root.largeFontSize*2
        //         Layout.preferredWidth: Layout.preferredHeight
        //         onClicked: sliderComp.clicked()
        //     }
            
        //     Rectangle {
        //         id: container
        //         color: "#f00"
        //         height: 20
        //         Layout.fillWidth: true
        //         radius: height / 2
        //         property double value:    0
        //       //  signal clicked(double value); 

        //         Rectangle {
        //             id: trough
        //             color: "#fc2"
        //             height: parent.height
        //             width: (value - from) / (to - from) * (container.width - control.width) + (control.width)
        //             radius: height / 2
        //         }

        //         Rectangle {
        //             id: control
        //             color: "#fce"
        //             width: parent.height
        //             height: parent.height
        //             radius: height / 2
        //             x: (value - from) / (to - from) * (container.width - control.width)

        //         }

        //         MouseArea {
        //             id: mouseArea

        //             anchors.fill: container
            
        //             drag {
        //                 target:   control
        //                 axis:     Drag.XAxis
        //                 maximumX: container.width - control.width
        //                 minimumX: 0
        //             }
                
        //             onPositionChanged:  if(drag.active) setPixels(control.x + 0.5 * control.width) // drag control
        //             onClicked: test_signal("Test string")//                         setPixels(mouse.x) // tap tray
        //         }
          
        //     }

        // }


        RowLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: root.smallSpacing

            PlasmaCore.IconItem {
                id: icon
                source: sliderComp.source
                visible: !sliderComp.useIconButton
                Layout.preferredHeight: root.largeFontSize*2
                Layout.preferredWidth: Layout.preferredHeight
            }
            
            PlasmaComponents2.ToolButton {
                id: iconButton
                visible: sliderComp.useIconButton
                iconSource: sliderComp.source
                Layout.preferredHeight: root.largeFontSize*2
                Layout.preferredWidth: Layout.preferredHeight
                onClicked: sliderComp.clicked()
            }
            
            PlasmaComponents.Slider {
                id: slider
                Layout.fillHeight: true
                Layout.fillWidth: true
                from: sliderComp.from
                to: sliderComp.to
                stepSize: 2
                snapMode: Slider.SnapAlways

                 background: Rectangle {
                    x: slider.leftPadding
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 20
                    width: slider.availableWidth
                    height: implicitHeight
                    radius: height / 2
                    color: "#161925"

                    Rectangle {
                        id: levelIndicator
                        width: (value - from) / (to - from) * (slider.width - handle.width) + (handle.width)
                        height: parent.height
                        color: "#161925"
                        radius: height / 2
                        border.width: 0
                        
                        anchors.verticalCenter: parent.verticalCenter
                        
                        
                    }

                    Item {
                        anchors.fill: levelIndicator
                       // x: container.x - 20
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: levelIndicator
                        }

                        LinearGradient {
                            anchors.fill: parent
                            start: Qt.point(levelIndicator.width, 0)
                            end: Qt.point(0, levelIndicator.height)
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#D300DC" }
                                GradientStop { position: 1.0; color: "#8700FF" }
                            }
                        }
                    }
                }

                handle: Rectangle {
                    id: handle
                    x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitWidth: levelIndicator.height
                    implicitHeight: levelIndicator.height
                    radius: height / 2
                    color: slider.pressed ? "#f0f0f0" : "#f6f6f6"
                    border.color: "#bdbebf"
                }
                
                onMoved: {
                    sliderComp.moved()
                }
            }
        }


    }

}
