import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: relayConfigRoot

    property alias cfg_relayEnabled: relayEnabledCheck.checked
    property alias cfg_relayDevice: relayDeviceField.text
    property alias cfg_relayMode: relayModeCombo.currentIndex
    property alias cfg_relayControlMode: relayControlModeCombo.currentIndex
    property alias cfg_relayCount: relayCountSpin.value
    property alias cfg_relayOnMask: onMaskSpin.value
    property alias cfg_relayEnabledMask: enabledMaskSpin.value
    property alias cfg_relayChannel: relayChannelSpin.value
    property alias cfg_relayByte1On: byte1OnField.text
    property alias cfg_relayByte2On: byte2OnField.text
    property alias cfg_relayByte3On: byte3OnField.text
    property alias cfg_relayByte4On: byte4OnField.text
    property alias cfg_relayByte1Off: byte1OffField.text
    property alias cfg_relayByte2Off: byte2OffField.text
    property alias cfg_relayByte3Off: byte3OffField.text
    property alias cfg_relayByte4Off: byte4OffField.text

    property bool showSimpleRelays: relayModeCombo.currentIndex === 0 && relayControlModeCombo.currentIndex === 0 || relayModeCombo.currentIndex === 1
    property bool showAdvancedSingle: relayModeCombo.currentIndex === 0 && relayControlModeCombo.currentIndex === 1
    property bool showAdvancedPerRelay: relayModeCombo.currentIndex === 0 && relayControlModeCombo.currentIndex === 2
    property int maxRelays: relayModeCombo.currentIndex === 0 ? 8 : 16
    property int selectedAdvRelay: advRelaySelector.currentIndex + 1

    property var advancedOnMap: ({})
    property var advancedOffMap: ({})

    Component.onCompleted: {
        for (var i = 1; i <= 8; i++) {
            var onVal = plasmoid.configuration["relayAdvOn_" + i] || ""
            var offVal = plasmoid.configuration["relayAdvOff_" + i] || ""
            advancedOnMap[i] = onVal !== "" ? onVal : "A0," + i.toString(16).toUpperCase().padStart(2, "0") + ",01," + ((0xA0 + i + 1) & 0xFF).toString(16).toUpperCase().padStart(2, "0")
            advancedOffMap[i] = offVal !== "" ? offVal : "A0," + i.toString(16).toUpperCase().padStart(2, "0") + ",00," + ((0xA0 + i) & 0xFF).toString(16).toUpperCase().padStart(2, "0")
        }
        advancedOnMapChanged()
        advancedOffMapChanged()
    }

    function getRelayState(index) {
        var bit = (1 << index)
        if ((enabledMaskSpin.value & bit) === 0) return 2
            if ((onMaskSpin.value & bit) !== 0) return 0
                return 1
    }

    function setRelayState(index, state) {
        var bit = (1 << index)
        if (state === 2) {
            enabledMaskSpin.value = enabledMaskSpin.value & ~bit
        } else {
            enabledMaskSpin.value = enabledMaskSpin.value | bit
            if (state === 0)
                onMaskSpin.value = onMaskSpin.value | bit
                else
                    onMaskSpin.value = onMaskSpin.value & ~bit
        }
    }

    function getChecksum(channel, state) {
        var sum = 0xA0 + channel + (state === "01" ? 1 : 0)
        return (sum & 0xFF).toString(16).toUpperCase().padStart(2, "0")
    }

    function getAdvBytes(relayNum, isOn) {
        if (isOn) {
            return advancedOnMap[relayNum] || "A0,01,01,A2"
        }
        return advancedOffMap[relayNum] || "A0,01,00,A1"
    }

    function setAdvBytes(relayNum, isOn, b1, b2, b3, b4) {
        var cleanStr = b1 + "," + b2 + "," + b3 + "," + b4
        if (isOn) {
            advancedOnMap[relayNum] = cleanStr
            if (plasmoid.configuration["relayAdvOn_" + relayNum] !== undefined) {
                plasmoid.configuration["relayAdvOn_" + relayNum] = cleanStr
            }
            advancedOnMapChanged()
        } else {
            advancedOffMap[relayNum] = cleanStr
            if (plasmoid.configuration["relayAdvOff_" + relayNum] !== undefined) {
                plasmoid.configuration["relayAdvOff_" + relayNum] = cleanStr
            }
            advancedOffMapChanged()
        }
    }

    QtObject {
        id: internalState
        property int onMaskValue: 1
        property int enabledMaskValue: 1
    }

    ScrollView {
        anchors.fill: parent
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 16

            SpinBox {
                id: onMaskSpin
                visible: false
                from: 0
                to: 255
                value: 1
            }
            SpinBox {
                id: enabledMaskSpin
                visible: false
                from: 0
                to: 255
                value: 1
            }

            GroupBox {
                Layout.fillWidth: true
                title: "USB Relay Module"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    CheckBox {
                        id: relayEnabledCheck
                        text: "Use USB relay (overrides Command On/Off fields)"
                    }

                    RowLayout {
                        Label { text: "Device path:"; Layout.preferredWidth: 130 }
                        TextField {
                            id: relayDeviceField
                            Layout.fillWidth: true
                            placeholderText: "/dev/ttyUSB0"
                            text: "/dev/ttyUSB0"
                            enabled: relayEnabledCheck.checked
                        }
                    }

                    RowLayout {
                        Label { text: "Protocol:"; Layout.preferredWidth: 130 }
                        ComboBox {
                            id: relayModeCombo
                            Layout.fillWidth: true
                            model: ["CH340 (4-Byte Hex)", "Simple Toggle (echo 1/0)"]
                            currentIndex: 0
                            enabled: relayEnabledCheck.checked
                        }
                    }

                    RowLayout {
                        visible: relayModeCombo.currentIndex === 0
                        Label { text: "Control Mode:"; Layout.preferredWidth: 130 }
                        ComboBox {
                            id: relayControlModeCombo
                            Layout.fillWidth: true
                            model: ["Simple (per-relay)", "Advanced (single relay)", "Advanced (per-relay bytes)"]
                            currentIndex: 0
                            enabled: relayEnabledCheck.checked
                        }
                    }

                    Text {
                        text: relayModeCombo.currentIndex === 1
                        ? "Simple Toggle: Sends 1 (on) or 0 (off) to the device per relay.\n\nSet up a udev rule for a stable device symlink if possible."
                        : (relayControlModeCombo.currentIndex === 0
                        ? "Simple: Set each relay's behavior below.\n\nON: Relay is ON when toggle ON, OFF when toggle OFF\nOFF: Relay is OFF when toggle ON, ON when toggle OFF\nDisabled: No command sent to this relay"
                        : (relayControlModeCombo.currentIndex === 1
                        ? "Advanced (single): Manually set the 4-byte hex command for one relay.\n\nFormat: Header, Channel, State, Checksum\nChecksum = (Header + Channel + State) & 0xFF"
                        : "Advanced (per-relay): Set the 4-byte hex command for each relay individually.\nSelect a relay below to edit its ON and OFF byte sequences."))
                        color: "#888"
                        font.pixelSize: 10
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        opacity: relayEnabledCheck.checked ? 1.0 : 0.5
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                title: "Relay Behavior"
                visible: showSimpleRelays
                enabled: relayEnabledCheck.checked

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    RowLayout {
                        Label { text: "Relays on board:"; Layout.preferredWidth: 130 }
                        SpinBox {
                            id: relayCountSpin
                            from: 0
                            to: maxRelays
                            value: 1
                        }
                    }

                    RowLayout {
                        spacing: 8
                        Label { text: "Relay"; Layout.preferredWidth: 50; font.bold: true }
                        Label { text: "Header"; Layout.preferredWidth: 60; font.bold: true }
                        Label { text: "Channel"; Layout.preferredWidth: 60; font.bold: true }
                        Label { text: "State"; Layout.preferredWidth: 80; font.bold: true }
                        Label { text: "Checksum"; Layout.preferredWidth: 60; font.bold: true }
                        Label { text: "Command"; Layout.fillWidth: true; font.bold: true }
                    }

                    ColumnLayout {
                        spacing: 4
                        Repeater {
                            model: relayCountSpin.value
                            delegate: RowLayout {
                                property int relayIdx: index
                                spacing: 8

                                Label {
                                    text: (relayIdx + 1).toString()
                                    Layout.preferredWidth: 50
                                }
                                Label {
                                    text: "A0"
                                    Layout.preferredWidth: 60
                                    font.family: "monospace"
                                }
                                Label {
                                    text: (relayIdx + 1).toString(16).toUpperCase().padStart(2, "0")
                                    Layout.preferredWidth: 60
                                    font.family: "monospace"
                                }
                                ComboBox {
                                    Layout.preferredWidth: 80
                                    model: ["ON", "OFF", "Disabled"]
                                    currentIndex: getRelayState(relayIdx)
                                    onActivated: setRelayState(relayIdx, currentIndex)
                                }
                                Label {
                                    text: (getRelayState(relayIdx) === 2) ? "--" : getChecksum(relayIdx + 1, getRelayState(relayIdx) === 0 ? "01" : "00")
                                    Layout.preferredWidth: 60
                                    font.family: "monospace"
                                }
                                Label {
                                    text: (getRelayState(relayIdx) === 2) ? "--" : "\\xA0\\x" + (relayIdx + 1).toString(16).toUpperCase().padStart(2, "0") + "\\x" + (getRelayState(relayIdx) === 0 ? "01" : "00") + "\\x" + getChecksum(relayIdx + 1, getRelayState(relayIdx) === 0 ? "01" : "00")
                                    Layout.fillWidth: true
                                    font.family: "monospace"
                                    font.pixelSize: 10
                                    color: "#888"
                                }
                            }
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                title: "ON Command Bytes"
                visible: showAdvancedSingle
                enabled: relayEnabledCheck.checked

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    RowLayout {
                        Label { text: "Channel:"; Layout.preferredWidth: 130 }
                        SpinBox {
                            id: relayChannelSpin
                            from: 1
                            to: 8
                            value: 1
                            onValueChanged: {
                                var hex = value.toString(16).toUpperCase().padStart(2, "0")
                                byte2OnField.text = hex
                                byte2OffField.text = hex
                            }
                        }
                    }

                    GridLayout {
                        columns: 5
                        columnSpacing: 6
                        rowSpacing: 6

                        Label { text: "Byte 1 (Header):" }
                        Label { text: "Byte 2 (Channel):" }
                        Label { text: "Byte 3 (State):" }
                        Label { text: "Byte 4 (Checksum):" }
                        Label { text: "" }

                        TextField { id: byte1OnField; text: "A0" }
                        TextField { id: byte2OnField; text: "01" }
                        TextField { id: byte3OnField; text: "01" }
                        TextField { id: byte4OnField; text: "A2" }
                        Text {
                            text: "→ \\x" + byte1OnField.text + "\\x" + byte2OnField.text + "\\x" + byte3OnField.text + "\\x" + byte4OnField.text
                            color: "#888"; font.family: "monospace"; font.pixelSize: 10
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                title: "OFF Command Bytes"
                visible: showAdvancedSingle
                enabled: relayEnabledCheck.checked

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    GridLayout {
                        columns: 5
                        columnSpacing: 6
                        rowSpacing: 6

                        Label { text: "Byte 1 (Header):" }
                        Label { text: "Byte 2 (Channel):" }
                        Label { text: "Byte 3 (State):" }
                        Label { text: "Byte 4 (Checksum):" }
                        Label { text: "" }

                        TextField { id: byte1OffField; text: "A0" }
                        TextField { id: byte2OffField; text: "01" }
                        TextField { id: byte3OffField; text: "00" }
                        TextField { id: byte4OffField; text: "A1" }
                        Text {
                            text: "→ \\x" + byte1OffField.text + "\\x" + byte2OffField.text + "\\x" + byte3OffField.text + "\\x" + byte4OffField.text
                            color: "#888"; font.family: "monospace"; font.pixelSize: 10
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                title: "Per-Relay Byte Editor"
                visible: showAdvancedPerRelay
                enabled: relayEnabledCheck.checked

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    RowLayout {
                        Label { text: "Relays on board:"; Layout.preferredWidth: 130 }
                        SpinBox {
                            id: advPerRelayCountSpin
                            from: 1
                            to: 8
                            value: 1
                        }
                    }

                    RowLayout {
                        Label { text: "Editing relay:"; Layout.preferredWidth: 130 }
                        ComboBox {
                            id: advRelaySelector
                            model: Array(advPerRelayCountSpin.value).fill(0).map((_, i) => "Relay " + (i + 1))
                            currentIndex: 0
                            Layout.preferredWidth: 120
                        }
                    }

                    Text {
                        text: "Edit the 4 bytes for the selected relay. Format: Header, Channel, State, Checksum"
                        color: "#888"
                        font.pixelSize: 10
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "ON Command:"
                        font.bold: true
                    }
                    RowLayout {
                        spacing: 4
                        TextField {
                            id: advOnB1
                            Layout.preferredWidth: 50
                            text: getAdvBytes(selectedAdvRelay, true).split(",")[0]
                            onEditingFinished: setAdvBytes(selectedAdvRelay, true, advOnB1.text, advOnB2.text, advOnB3.text, advOnB4.text)
                        }
                        TextField {
                            id: advOnB2
                            Layout.preferredWidth: 50
                            text: getAdvBytes(selectedAdvRelay, true).split(",")[1]
                            onEditingFinished: setAdvBytes(selectedAdvRelay, true, advOnB1.text, advOnB2.text, advOnB3.text, advOnB4.text)
                        }
                        TextField {
                            id: advOnB3
                            Layout.preferredWidth: 50
                            text: getAdvBytes(selectedAdvRelay, true).split(",")[2]
                            onEditingFinished: setAdvBytes(selectedAdvRelay, true, advOnB1.text, advOnB2.text, advOnB3.text, advOnB4.text)
                        }
                        TextField {
                            id: advOnB4
                            Layout.preferredWidth: 50
                            text: getAdvBytes(selectedAdvRelay, true).split(",")[3]
                            onEditingFinished: setAdvBytes(selectedAdvRelay, true, advOnB1.text, advOnB2.text, advOnB3.text, advOnB4.text)
                        }
                        Text {
                            text: "→ \\x" + advOnB1.text + "\\x" + advOnB2.text + "\\x" + advOnB3.text + "\\x" + advOnB4.text
                            color: "#888"; font.family: "monospace"; font.pixelSize: 10
                        }
                    }

                    Text {
                        text: "OFF Command:"
                        font.bold: true
                    }
                    RowLayout {
                        spacing: 4
                        TextField {
                            id: advOffB1
                            Layout.preferredWidth: 50
                            text: getAdvBytes(selectedAdvRelay, false).split(",")[0]
                            onEditingFinished: setAdvBytes(selectedAdvRelay, false, advOffB1.text, advOffB2.text, advOffB3.text, advOffB4.text)
                        }
                        TextField {
                            id: advOffB2
                            Layout.preferredWidth: 50
                            text: getAdvBytes(selectedAdvRelay, false).split(",")[1]
                            onEditingFinished: setAdvBytes(selectedAdvRelay, false, advOffB1.text, advOffB2.text, advOffB3.text, advOffB4.text)
                        }
                        TextField {
                            id: advOffB3
                            Layout.preferredWidth: 50
                            text: getAdvBytes(selectedAdvRelay, false).split(",")[2]
                            onEditingFinished: setAdvBytes(selectedAdvRelay, false, advOffB1.text, advOffB2.text, advOffB3.text, advOffB4.text)
                        }
                        TextField {
                            id: advOffB4
                            Layout.preferredWidth: 50
                            text: getAdvBytes(selectedAdvRelay, false).split(",")[3]
                            onEditingFinished: setAdvBytes(selectedAdvRelay, false, advOffB1.text, advOffB2.text, advOffB3.text, advOffB4.text)
                        }
                        Text {
                            text: "→ \\x" + advOffB1.text + "\\x" + advOffB2.text + "\\x" + advOffB3.text + "\\x" + advOffB4.text
                            color: "#888"; font.family: "monospace"; font.pixelSize: 10
                        }
                    }

                    Text {
                        text: "All relays:"
                        font.bold: true
                        Layout.topMargin: 8
                    }
                    ColumnLayout {
                        spacing: 2
                        Repeater {
                            model: advPerRelayCountSpin.value
                            delegate: RowLayout {
                                spacing: 8
                                Label {
                                    text: "Relay " + (index + 1) + ":"
                                    Layout.preferredWidth: 60
                                    font.pixelSize: 10
                                }
                                Label {
                                    text: "ON:  \\x" + getAdvBytes(index + 1, true).split(",").join("\\x")
                                    font.family: "monospace"
                                    font.pixelSize: 10
                                    color: "#888"
                                }
                                Label {
                                    text: "OFF: \\x" + getAdvBytes(index + 1, false).split(",").join("\\x")
                                    font.family: "monospace"
                                    font.pixelSize: 10
                                    color: "#888"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
