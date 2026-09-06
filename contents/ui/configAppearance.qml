import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Item {
    property alias cfg_colorOn: colorOnField.text
    property alias cfg_colorOff: colorOffField.text
    property alias cfg_textColorOn: textColorOnField.text
    property alias cfg_textColorOff: textColorOffField.text
    property alias cfg_borderColorOn: borderColorOnField.text
    property alias cfg_borderColorOff: borderColorOffField.text
    property alias cfg_borderWidth: borderWidthSpin.value
    property alias cfg_trackWidth: trackWidthSpin.value
    property alias cfg_trackHeight: trackHeightSpin.value
    property alias cfg_trackRadius: trackRadiusSpin.value
    property alias cfg_ballSize: ballSizeSpin.value
    property alias cfg_ballRadius: ballRadiusSpin.value
    property alias cfg_ballColor: ballColorField.text
    property alias cfg_ballBorderColor: ballBorderColorField.text
    property alias cfg_ballBorderWidth: ballBorderWidthSpin.value
    property alias cfg_buttonWidth: buttonWidthSpin.value
    property alias cfg_buttonHeight: buttonHeightSpin.value
    property alias cfg_buttonBgColor: buttonBgColorField.text
    property alias cfg_buttonBgRadius: buttonBgRadiusSpin.value
    property alias cfg_buttonBorderColor: buttonBorderColorField.text
    property alias cfg_buttonBorderWidth: buttonBorderWidthSpin.value
    property alias cfg_backgroundOpacity: opacitySpin.value
    property alias cfg_powerIconSize: powerIconSizeSpin.value

    property string colorDialogTarget: ""

    function openColorDialog(target, currentColor) {
        colorDialogTarget = target
        colorDialog.selectedColor = currentColor
        colorDialog.open()
    }

    ColorDialog {
        id: colorDialog
        modality: Qt.WindowModal
        options: ColorDialog.ShowAlphaChannel

        onAccepted: {
            var r = Math.round(selectedColor.r * 255)
            var g = Math.round(selectedColor.g * 255)
            var b = Math.round(selectedColor.b * 255)
            var hex = "#" + r.toString(16).padStart(2, "0").toUpperCase()
            + g.toString(16).padStart(2, "0").toUpperCase()
            + b.toString(16).padStart(2, "0").toUpperCase()
            if (colorDialogTarget === "colorOn") colorOnField.text = hex
                else if (colorDialogTarget === "colorOff") colorOffField.text = hex
                    else if (colorDialogTarget === "textColorOn") textColorOnField.text = hex
                        else if (colorDialogTarget === "textColorOff") textColorOffField.text = hex
                            else if (colorDialogTarget === "borderColorOn") borderColorOnField.text = hex
                                else if (colorDialogTarget === "borderColorOff") borderColorOffField.text = hex
                                    else if (colorDialogTarget === "ballColor") ballColorField.text = hex
                                        else if (colorDialogTarget === "ballBorderColor") ballBorderColorField.text = hex
                                            else if (colorDialogTarget === "buttonBgColor") buttonBgColorField.text = hex
                                                else if (colorDialogTarget === "buttonBorderColor") buttonBorderColorField.text = hex
        }
    }

    ScrollView {
        anchors.fill: parent
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 16

            GroupBox {
                Layout.fillWidth: true
                title: "State Colors"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    RowLayout {
                        Label { text: "Background On:"; Layout.preferredWidth: 130 }
                        TextField {
                            id: colorOnField
                            Layout.fillWidth: true
                            text: "#4CAF50"
                        }
                        Row {
                            spacing: 3
                            Repeater {
                                model: ["#4CAF50", "#F44336", "#2196F3", "#9C27B0", "#FF9800",
                                "#009688", "#795548", "#607D8B", "#FFFFFF", "#000000"]
                                Rectangle {
                                    width: 16; height: 16
                                    color: modelData
                                    border.width: 1; border.color: "#888"; radius: 2
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: colorOnField.text = modelData
                                    }
                                }
                            }
                        }
                        Rectangle {
                            width: 20; height: 20
                            color: colorOnField.text
                            border.width: 1; border.color: "#888"; radius: 3
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: openColorDialog("colorOn", colorOnField.text)
                            }
                        }
                    }

                    RowLayout {
                        Label { text: "Background Off:"; Layout.preferredWidth: 130 }
                        TextField {
                            id: colorOffField
                            Layout.fillWidth: true
                            text: "#F44336"
                        }
                        Row {
                            spacing: 3
                            Repeater {
                                model: ["#4CAF50", "#F44336", "#2196F3", "#9C27B0", "#FF9800",
                                "#009688", "#795548", "#607D8B", "#FFFFFF", "#000000"]
                                Rectangle {
                                    width: 16; height: 16
                                    color: modelData
                                    border.width: 1; border.color: "#888"; radius: 2
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: colorOffField.text = modelData
                                    }
                                }
                            }
                        }
                        Rectangle {
                            width: 20; height: 20
                            color: colorOffField.text
                            border.width: 1; border.color: "#888"; radius: 3
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: openColorDialog("colorOff", colorOffField.text)
                            }
                        }
                    }

                    RowLayout {
                        Label { text: "Border On:"; Layout.preferredWidth: 130 }
                        TextField {
                            id: borderColorOnField
                            Layout.fillWidth: true
                            text: "#45A049"
                        }
                        Row {
                            spacing: 3
                            Repeater {
                                model: ["#4CAF50", "#F44336", "#2196F3", "#9C27B0", "#FF9800",
                                "#009688", "#795548", "#607D8B", "#FFFFFF", "#000000"]
                                Rectangle {
                                    width: 16; height: 16
                                    color: modelData
                                    border.width: 1; border.color: "#888"; radius: 2
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: borderColorOnField.text = modelData
                                    }
                                }
                            }
                        }
                        Rectangle {
                            width: 20; height: 20
                            color: borderColorOnField.text
                            border.width: 1; border.color: "#888"; radius: 3
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: openColorDialog("borderColorOn", borderColorOnField.text)
                            }
                        }
                    }

                    RowLayout {
                        Label { text: "Border Off:"; Layout.preferredWidth: 130 }
                        TextField {
                            id: borderColorOffField
                            Layout.fillWidth: true
                            text: "#D32F2F"
                        }
                        Row {
                            spacing: 3
                            Repeater {
                                model: ["#4CAF50", "#F44336", "#2196F3", "#9C27B0", "#FF9800",
                                "#009688", "#795548", "#607D8B", "#FFFFFF", "#000000"]
                                Rectangle {
                                    width: 16; height: 16
                                    color: modelData
                                    border.width: 1; border.color: "#888"; radius: 2
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: borderColorOffField.text = modelData
                                    }
                                }
                            }
                        }
                        Rectangle {
                            width: 20; height: 20
                            color: borderColorOffField.text
                            border.width: 1; border.color: "#888"; radius: 3
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: openColorDialog("borderColorOff", borderColorOffField.text)
                            }
                        }
                    }

                    RowLayout {
                        Label { text: "Text On:"; Layout.preferredWidth: 130 }
                        TextField {
                            id: textColorOnField
                            Layout.fillWidth: true
                            text: "#FFFFFF"
                        }
                        Row {
                            spacing: 3
                            Repeater {
                                model: ["#4CAF50", "#F44336", "#2196F3", "#9C27B0", "#FF9800",
                                "#009688", "#795548", "#607D8B", "#FFFFFF", "#000000"]
                                Rectangle {
                                    width: 16; height: 16
                                    color: modelData
                                    border.width: 1; border.color: "#888"; radius: 2
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: textColorOnField.text = modelData
                                    }
                                }
                            }
                        }
                        Rectangle {
                            width: 20; height: 20
                            color: textColorOnField.text
                            border.width: 1; border.color: "#888"; radius: 3
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: openColorDialog("textColorOn", textColorOnField.text)
                            }
                        }
                    }

                    RowLayout {
                        Label { text: "Text Off:"; Layout.preferredWidth: 130 }
                        TextField {
                            id: textColorOffField
                            Layout.fillWidth: true
                            text: "#FFFFFF"
                        }
                        Row {
                            spacing: 3
                            Repeater {
                                model: ["#4CAF50", "#F44336", "#2196F3", "#9C27B0", "#FF9800",
                                "#009688", "#795548", "#607D8B", "#FFFFFF", "#000000"]
                                Rectangle {
                                    width: 16; height: 16
                                    color: modelData
                                    border.width: 1; border.color: "#888"; radius: 2
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: textColorOffField.text = modelData
                                    }
                                }
                            }
                        }
                        Rectangle {
                            width: 20; height: 20
                            color: textColorOffField.text
                            border.width: 1; border.color: "#888"; radius: 3
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: openColorDialog("textColorOff", textColorOffField.text)
                            }
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                title: "Slide Switch"
                enabled: plasmoid.configuration.buttonStyle === 0

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    RowLayout {
                        Label { text: "Track Width (px):"; Layout.preferredWidth: 130 }
                        SpinBox {
                            id: trackWidthSpin
                            from: 20; to: 200; value: 40
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Label { text: "Track Height (px):"; Layout.preferredWidth: 130 }
                        SpinBox {
                            id: trackHeightSpin
                            from: 10; to: 50; value: 15
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Label { text: "Track Radius (0=auto):"; Layout.preferredWidth: 130 }
                        SpinBox {
                            id: trackRadiusSpin
                            from: 0; to: 50; value: 0
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Label { text: "Ball Size (px):"; Layout.preferredWidth: 130 }
                        SpinBox {
                            id: ballSizeSpin
                            from: 8; to: 40; value: 18
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Label { text: "Ball Radius (0=auto):"; Layout.preferredWidth: 130 }
                        SpinBox {
                            id: ballRadiusSpin
                            from: 0; to: 20; value: 0
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Label { text: "Ball Color:"; Layout.preferredWidth: 130 }
                        TextField {
                            id: ballColorField
                            Layout.fillWidth: true
                            text: "#FFFFFF"
                        }
                        Row {
                            spacing: 3
                            Repeater {
                                model: ["#4CAF50", "#F44336", "#2196F3", "#9C27B0", "#FF9800",
                                "#009688", "#795548", "#607D8B", "#FFFFFF", "#000000"]
                                Rectangle {
                                    width: 16; height: 16
                                    color: modelData
                                    border.width: 1; border.color: "#888"; radius: 2
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: ballColorField.text = modelData
                                    }
                                }
                            }
                        }
                        Rectangle {
                            width: 20; height: 20
                            color: ballColorField.text
                            border.width: 1; border.color: "#888"; radius: 3
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: openColorDialog("ballColor", ballColorField.text)
                            }
                        }
                    }

                    RowLayout {
                        Label { text: "Ball Border Color:"; Layout.preferredWidth: 130 }
                        TextField {
                            id: ballBorderColorField
                            Layout.fillWidth: true
                            text: "#555555"
                        }
                        Row {
                            spacing: 3
                            Repeater {
                                model: ["#4CAF50", "#F44336", "#2196F3", "#9C27B0", "#FF9800",
                                "#009688", "#795548", "#607D8B", "#FFFFFF", "#000000"]
                                Rectangle {
                                    width: 16; height: 16
                                    color: modelData
                                    border.width: 1; border.color: "#888"; radius: 2
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: ballBorderColorField.text = modelData
                                    }
                                }
                            }
                        }
                        Rectangle {
                            width: 20; height: 20
                            color: ballBorderColorField.text
                            border.width: 1; border.color: "#888"; radius: 3
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: openColorDialog("ballBorderColor", ballBorderColorField.text)
                            }
                        }
                    }

                    RowLayout {
                        Label { text: "Ball Border Width (px):"; Layout.preferredWidth: 130 }
                        SpinBox {
                            id: ballBorderWidthSpin
                            from: 0; to: 5; value: 1
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                title: "Overall Button"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    RowLayout {
                        Label { text: "Width (px, 0=auto):"; Layout.preferredWidth: 130 }
                        SpinBox {
                            id: buttonWidthSpin
                            from: 0; to: 500; value: 0
                            Layout.fillWidth: true
                            enabled: plasmoid.configuration.buttonStyle === 1
                        }
                    }

                    RowLayout {
                        Label { text: "Height (px, 0=auto):"; Layout.preferredWidth: 130 }
                        SpinBox {
                            id: buttonHeightSpin
                            from: 0; to: 500; value: 0
                            Layout.fillWidth: true
                            enabled: plasmoid.configuration.buttonStyle === 1
                        }
                    }

                    RowLayout {
                        Label { text: "Radius (px):"; Layout.preferredWidth: 130 }
                        SpinBox {
                            id: buttonBgRadiusSpin
                            from: 0; to: 50; value: 8
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Label { text: "Background Color:"; Layout.preferredWidth: 130 }
                        TextField {
                            id: buttonBgColorField
                            Layout.fillWidth: true
                            placeholderText: "transparent"
                        }
                        Row {
                            spacing: 3
                            Repeater {
                                model: ["#4CAF50", "#F44336", "#2196F3", "#9C27B0", "#FF9800",
                                "#009688", "#795548", "#607D8B", "#FFFFFF", "#000000"]
                                Rectangle {
                                    width: 16; height: 16
                                    color: modelData
                                    border.width: 1; border.color: "#888"; radius: 2
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: buttonBgColorField.text = modelData
                                    }
                                }
                            }
                        }
                        Rectangle {
                            width: 20; height: 20
                            color: buttonBgColorField.text === "transparent" || buttonBgColorField.text === "" ? "transparent" : buttonBgColorField.text
                            border.width: 1; border.color: "#888"; radius: 3
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var c = (buttonBgColorField.text === "transparent" || buttonBgColorField.text === "") ? "#000000" : buttonBgColorField.text
                                    openColorDialog("buttonBgColor", c)
                                }
                            }
                        }
                    }

                    RowLayout {
                        Label { text: "Border Color:"; Layout.preferredWidth: 130 }
                        TextField {
                            id: buttonBorderColorField
                            Layout.fillWidth: true
                            placeholderText: "transparent"
                        }
                        Row {
                            spacing: 3
                            Repeater {
                                model: ["#4CAF50", "#F44336", "#2196F3", "#9C27B0", "#FF9800",
                                "#009688", "#795548", "#607D8B", "#FFFFFF", "#000000"]
                                Rectangle {
                                    width: 16; height: 16
                                    color: modelData
                                    border.width: 1; border.color: "#888"; radius: 2
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: buttonBorderColorField.text = modelData
                                    }
                                }
                            }
                        }
                        Rectangle {
                            width: 20; height: 20
                            color: buttonBorderColorField.text === "transparent" || buttonBorderColorField.text === "" ? "transparent" : buttonBorderColorField.text
                            border.width: 1; border.color: "#888"; radius: 3
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var c = (buttonBorderColorField.text === "transparent" || buttonBorderColorField.text === "") ? "#000000" : buttonBorderColorField.text
                                    openColorDialog("buttonBorderColor", c)
                                }
                            }
                        }
                    }

                    RowLayout {
                        Label { text: "Border Width (px):"; Layout.preferredWidth: 130 }
                        SpinBox {
                            id: buttonBorderWidthSpin
                            from: 0; to: 10; value: 0
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Label { text: "State Border Width (px):"; Layout.preferredWidth: 130 }
                        SpinBox {
                            id: borderWidthSpin
                            from: 0; to: 10; value: 1
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Label { text: "Opacity (%):"; Layout.preferredWidth: 130 }
                        SpinBox {
                            id: opacitySpin
                            from: 0; to: 100; value: 100
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Label { text: "Offset X (px):"; Layout.preferredWidth: 130 }
                        SpinBox {
                            id: offsetXSpin
                            from: -50; to: 50; value: 0
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Label { text: "Offset Y (px):"; Layout.preferredWidth: 130 }
                        SpinBox {
                            id: offsetYSpin
                            from: -50; to: 50; value: 0
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Label { text: "Power Icon Size (%):"; Layout.preferredWidth: 130 }
                        SpinBox {
                            id: powerIconSizeSpin
                            from: 10; to: 100; value: 50
                            Layout.fillWidth: true
                            enabled: plasmoid.configuration.buttonStyle === 3
                        }
                    }
                }
            }
        }
    }
}
