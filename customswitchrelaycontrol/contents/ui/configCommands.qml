import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: commandsConfigRoot

    property alias cfg_commandOn: commandOnField.text
    property alias cfg_commandOff: commandOffField.text
    property alias cfg_startupState: startupStateCombo.currentIndex
    property alias cfg_executeCommandOnStartup: executeCommandCheck.checked
    property alias cfg_watcherEnabled: watcherEnabledCheck.checked
    property alias cfg_watcherCommand: watcherCommandField.text
    property alias cfg_watcherInterval: watcherIntervalSpin.value

    // Timer System Properties
    property alias cfg_autoOffEnabled: autoOffEnabledCheck.checked
    property alias cfg_autoOffDuration: autoOffDurationSpin.value
    property alias cfg_autoOnEnabled: autoOnEnabledCheck.checked
    property alias cfg_autoOnDuration: autoOnDurationSpin.value
    property alias cfg_autoOffRepeatState: scheduleActionCombo.currentIndex
    property alias cfg_customTimerCommandEnabled: customTimerCommandCheck.checked
    property alias cfg_customTimerOnCommand: customTimerOnField.text
    property alias cfg_customTimerOffCommand: customTimerOffField.text

    // Scheduler Task Properties
    property alias cfg_autoOffRepeat: autoOffRepeatCombo.currentIndex
    property alias cfg_autoOffHour: autoOffHourSpin.value
    property alias cfg_autoOffMinute: autoOffMinuteSpin.value
    property alias cfg_customScheduleCommandEnabled: customScheduleCommandCheck.checked
    property alias cfg_customScheduleCommand: customScheduleField.text

    // Matrix Array Proxy for Custom Weekday layout
    property alias cfg_relayScheduleDaysActive: daysSerializationField.text

    property var daysMap: [false, false, false, false, false, false, false]

    TextField {
        id: daysSerializationField
        visible: false
        onTextChanged: {
            if (!text) return
                var tokens = text.split(",")
                if (tokens.length === 7) {
                    for (var i = 0; i < 7; i++) {
                        daysMap[i] = (tokens[i] === "1")
                    }
                    daysMapChanged()
                }
        }
    }

    function syncDaysToBackend() {
        var buf = []
        for (var i = 0; i < 7; i++) {
            buf.push(daysMap[i] ? "1" : "0")
        }
        daysSerializationField.text = buf.join(",")
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
                title: "Global Execution Commands"
                enabled: !plasmoid.configuration.relayEnabled

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8
                    RowLayout {
                        Label { text: "Command On:"; Layout.preferredWidth: 130 }
                        TextField { id: commandOnField; Layout.fillWidth: true; placeholderText: "Global command when turned ON" }
                    }
                    RowLayout {
                        Label { text: "Command Off:"; Layout.preferredWidth: 130 }
                        TextField { id: commandOffField; Layout.fillWidth: true; placeholderText: "Global command when turned OFF" }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                title: "Countdown Timer Tasks"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    RowLayout {
                        CheckBox { id: autoOffEnabledCheck; text: "Enable Auto-Off Timer after:" }
                        SpinBox { id: autoOffDurationSpin; from: 1; to: 1440; value: 30; enabled: autoOffEnabledCheck.checked }
                        Label { text: "minutes" }
                    }

                    RowLayout {
                        CheckBox { id: autoOnEnabledCheck; text: "Enable Auto-On Timer after:" }
                        SpinBox { id: autoOnDurationSpin; from: 1; to: 1440; value: 30; enabled: autoOnEnabledCheck.checked }
                        Label { text: "minutes" }
                    }

                    CheckBox {
                        id: customTimerCommandCheck
                        text: "Execute Custom Event Commands instead of Global options"
                        Layout.topMargin: 6
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: customTimerCommandCheck.checked
                        spacing: 6
                        RowLayout {
                            Label { text: "Timer On Script:"; Layout.preferredWidth: 130 }
                            TextField { id: customTimerOnField; Layout.fillWidth: true; placeholderText: "Runs when timer triggers ON" }
                        }
                        RowLayout {
                            Label { text: "Timer Off Script:"; Layout.preferredWidth: 130 }
                            TextField { id: customTimerOffField; Layout.fillWidth: true; placeholderText: "Runs when timer triggers OFF" }
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                title: "Task Scheduler"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    RowLayout {
                        Label { text: "Schedule Event Trigger:"; Layout.preferredWidth: 130 }
                        ComboBox {
                            id: autoOffRepeatCombo
                            Layout.fillWidth: true
                            model: ["Disabled", "Daily", "Weekly (Monday)", "Weekdays (Mon-Fri)", "Weekends (Sat-Sun)", "Custom Days Schedule"]
                            currentIndex: 0
                        }
                    }

                    RowLayout {
                        visible: autoOffRepeatCombo.currentIndex > 0
                        Label { text: "Target Event Time:"; Layout.preferredWidth: 130 }
                        SpinBox { id: autoOffHourSpin; from: 0; to: 23; value: 12 }
                        Label { text: "h" }
                        SpinBox { id: autoOffMinuteSpin; from: 0; to: 59; value: 0 }
                        Label { text: "m" }
                    }

                    RowLayout {
                        visible: autoOffRepeatCombo.currentIndex > 0
                        Label { text: "Scheduled Action:"; Layout.preferredWidth: 130 }
                        ComboBox {
                            id: scheduleActionCombo
                            Layout.fillWidth: true
                            model: ["Force Switch OFF", "Force Switch ON", "Execute Custom Script"]
                        }
                    }

                    // Interactive Custom Schedule Days Grid
                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: autoOffRepeatCombo.currentIndex === 5
                        Layout.topMargin: 4
                        Label { text: "Active Scheduled Weekdays:"; font.bold: true }
                        RowLayout {
                            spacing: 10
                            Repeater {
                                model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                                CheckBox {
                                    text: modelData
                                    checked: daysMap[index]
                                    onCheckedChanged: {
                                        daysMap[index] = checked
                                        syncDaysToBackend()
                                    }
                                }
                            }
                        }
                    }

                    CheckBox {
                        id: customScheduleCommandCheck
                        text: "Execute Custom Scheduler Task Script"
                        visible: autoOffRepeatCombo.currentIndex > 0
                        Layout.topMargin: 6
                    }

                    RowLayout {
                        visible: customScheduleCommandCheck.checked && autoOffRepeatCombo.currentIndex > 0
                        Label { text: "Scheduler Script:"; Layout.preferredWidth: 130 }
                        TextField { id: customScheduleField; Layout.fillWidth: true; placeholderText: "Custom bash script to run on schedule block" }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                title: "State Monitor Watcher"
                ColumnLayout {
                    anchors.fill: parent; spacing: 8
                    CheckBox { id: watcherEnabledCheck; text: "Enable state polling checker" }
                    RowLayout {
                        Label { text: "Query Command:"; Layout.preferredWidth: 130 }
                        TextField { id: watcherCommandField; Layout.fillWidth: true; placeholderText: "Command to evaluate state (Exit Code 0 = ON)"; enabled: watcherEnabledCheck.checked }
                    }
                    RowLayout {
                        Label { text: "Query Interval:"; Layout.preferredWidth: 130 }
                        SpinBox { id: watcherIntervalSpin; from: 1; to: 3600; value: 5; enabled: watcherEnabledCheck.checked }
                        Label { text: "seconds" }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true; title: "Startup Context Management"
                ColumnLayout {
                    anchors.fill: parent; spacing: 8
                    RowLayout {
                        Label { text: "Default State:"; Layout.preferredWidth: 130 }
                        ComboBox { id: startupStateCombo; Layout.fillWidth: true; model: ["OFF", "ON"] }
                    }
                    CheckBox { id: executeCommandCheck; text: "Enforce execution routing routines on startup" }
                }
            }
        }
    }
}
