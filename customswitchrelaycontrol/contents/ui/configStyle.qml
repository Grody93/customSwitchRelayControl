import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    property alias cfg_buttonStyle: buttonStyleCombo.currentIndex
    property alias cfg_powerShape: powerShapeCombo.currentIndex
    property alias cfg_powerIconSize: powerIconSizeSpin.value
    property alias cfg_powerBorderVisible: powerBorderVisibleCheck.checked
    property alias cfg_powerImagePadding: powerImagePaddingSpin.value
    property alias cfg_powerLabelSpacing: powerLabelSpacingSpin.value
    property alias cfg_fontPosition: fontPositionCombo.currentIndex
    property alias cfg_fontFamily: fontFamilyField.text
    property alias cfg_fontWeight: fontWeightCombo.currentIndex
    property alias cfg_fontLetterSpacing: fontLetterSpacingSpin.value
    property alias cfg_fontSize: fontSizeSpin.value
    property alias cfg_fontPadding: fontPaddingSpin.value
    property alias cfg_labelText: labelTextField.text
    property alias cfg_tooltipText: tooltipField.text
    property alias cfg_powerIconOn: powerIconOnField.text
    property alias cfg_powerIconOff: powerIconOffField.text

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
                title: "Label"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    RowLayout {
                        Label { text: "Text:"; Layout.preferredWidth: 130 }
                        TextField {
                            id: labelTextField
                            Layout.fillWidth: true
                            placeholderText: "Switch"
                        }
                    }

                    RowLayout {
                        Label { text: "Tooltip:"; Layout.preferredWidth: 130 }
                        TextField {
                            id: tooltipField
                            Layout.fillWidth: true
                            placeholderText: "Custom Switch"
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                title: "Button Style"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    RowLayout {
                        Label { text: "Style:"; Layout.preferredWidth: 130 }
                        ComboBox {
                            id: buttonStyleCombo
                            Layout.fillWidth: true
                            model: ["Slide Switch", "Button", "Checkbox", "Power Button"]
                            currentIndex: 0
                        }
                    }

                    RowLayout {
                        Label { text: "Power Shape:"; Layout.preferredWidth: 130 }
                        ComboBox {
                            id: powerShapeCombo
                            Layout.fillWidth: true
                            model: ["Circle", "Rounded Square"]
                            currentIndex: 0
                            enabled: buttonStyleCombo.currentIndex === 3
                        }
                    }

                    RowLayout {
                        Label { text: "Power Icon Size (%):"; Layout.preferredWidth: 130 }
                        SpinBox {
                            id: powerIconSizeSpin
                            from: 10; to: 100; value: 50
                            enabled: buttonStyleCombo.currentIndex === 3
                        }
                    }

                    RowLayout {
                        Label { text: "Power Border:"; Layout.preferredWidth: 130 }
                        CheckBox {
                            id: powerBorderVisibleCheck
                            text: "Show outer ring"
                            checked: true
                            enabled: buttonStyleCombo.currentIndex === 3
                        }
                    }

                    RowLayout {
                        Label { text: "Image Padding (px):"; Layout.preferredWidth: 130 }
                        SpinBox {
                            id: powerImagePaddingSpin
                            from: 0; to: 20; value: 0
                            enabled: buttonStyleCombo.currentIndex === 3
                        }
                    }

                    RowLayout {
                        Label { text: "Label Spacing (px):"; Layout.preferredWidth: 130 }
                        SpinBox {
                            id: powerLabelSpacingSpin
                            from: 0; to: 20; value: 2
                            enabled: buttonStyleCombo.currentIndex === 3
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                title: "Power Button Icons"
                enabled: buttonStyleCombo.currentIndex === 3

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    RowLayout {
                        Label { text: "Icon On (path):"; Layout.preferredWidth: 130 }
                        TextField {
                            id: powerIconOnField
                            Layout.fillWidth: true
                            placeholderText: "/path/to/on.png"
                            enabled: buttonStyleCombo.currentIndex === 3
                        }
                    }

                    RowLayout {
                        Label { text: "Icon Off (path):"; Layout.preferredWidth: 130 }
                        TextField {
                            id: powerIconOffField
                            Layout.fillWidth: true
                            placeholderText: "/path/to/off.png"
                            enabled: buttonStyleCombo.currentIndex === 3
                        }
                    }

                    Text {
                        text: "PNG or SVG. Use absolute path. Replaces the default power symbol."
                        color: "#888"; font.pixelSize: 10; wrapMode: Text.WordWrap; Layout.fillWidth: true
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                title: "Font Properties"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    RowLayout {
                        Label { text: "Size (px, 0=default):"; Layout.preferredWidth: 130 }
                        SpinBox { id: fontSizeSpin; from: 0; to: 36; value: 0 }
                    }
                    RowLayout {
                        Label { text: "Position:"; Layout.preferredWidth: 130 }
                        ComboBox { id: fontPositionCombo; Layout.fillWidth: true; model: ["Top", "Bottom"]; currentIndex: 1 }
                    }
                    RowLayout {
                        Label { text: "Family:"; Layout.preferredWidth: 130 }
                        TextField { id: fontFamilyField; Layout.fillWidth: true; placeholderText: "default" }
                    }
                    RowLayout {
                        Label { text: "Weight:"; Layout.preferredWidth: 130 }
                        ComboBox { id: fontWeightCombo; Layout.fillWidth: true; model: ["Normal", "Bold", "Light", "Black"]; currentIndex: 0 }
                    }
                    RowLayout {
                        Label { text: "Letter Spacing (px):"; Layout.preferredWidth: 130 }
                        SpinBox { id: fontLetterSpacingSpin; from: -5; to: 20; value: 0 }
                    }
                    RowLayout {
                        Label { text: "Padding spacing (px):"; Layout.preferredWidth: 130 }
                        SpinBox { id: fontPaddingSpin; from: 0; to: 20; value: 2 }
                    }
                }
            }
        }
    }
}
