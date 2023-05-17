import QtQuick 2.0
import QtQuick.Layouts 1.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents2
import org.kde.plasma.components 3.0 as PlasmaComponents

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
                Layout.fillWidth: true
                from: sliderComp.from
                to: sliderComp.to
                stepSize: 2
                snapMode: Slider.SnapAlways

                background: Rectangle {
                    x: slider.leftPadding
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 17
                    width: slider.availableWidth
                    height: parent.height
                    radius: height / 2
                    color: root.isDarkTheme ? Qt.lighter(root.themeBgColor, 1.8) : Qt.darker(root.themeBgColor, 1.2)

                    Rectangle {
                        id: levelIndicator
                        width: (value - from) / (to - from) * (slider.width - handle.width) + (handle.width)
                        height: parent.height
                        color:  root.themeHighlightColor
                        radius: height / 2
                        border.width: 0
                        anchors.verticalCenter: parent.verticalCenter
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
