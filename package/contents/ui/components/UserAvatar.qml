import QtQuick 2.0
import QtQuick.Layouts 1.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents2
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.13 as Kirigami
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
import org.kde.kcoreaddons 1.0 as KCoreAddons
import "../lib" as Lib

Lib.Card {
    id: useraAvatar

    Layout.preferredWidth: (root.fullRepWidth / 3) * 2.3
    Layout.preferredHeight: root.sectionHeight/3.5

    KCoreAddons.KUser {
      id: kuser
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: root.mediumSpacing
        
        clip: true
        
        Rectangle {
            width: (35 * PlasmaCore.Units.devicePixelRatio)  
            height: width
            color: "transparent"
            radius: width / 2
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHLeft
            Kirigami.Avatar {
                source: kuser.faceIconUrl
                anchors {
                    fill: parent
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: false
                    onClicked: {
                        KQuickAddons.KCMShell.openSystemSettings("kcm_users")
                        root.toggle()
                    }
                }
            }
        }

        PlasmaComponents.Label {
            id: greeting
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: root.smallSpacing
            text: 'Hi, ' + kuser.fullName
            font.pixelSize:  root.largeFontSize
            font.weight: Font.Bold
            horizontalAlignment:  Qt.AlignLeft
            verticalAlignment: Qt.AlignVCenter
            wrapMode: Text.WordWrap
        }
    }
}



