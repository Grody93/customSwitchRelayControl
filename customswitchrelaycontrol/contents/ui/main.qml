/*
 * Custom Switch Relay Control v2
 * Fully functional Timer & Task Scheduler Core implementation.
 */

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    property bool switchState: false
    property int executionType: 0

    preferredRepresentation: fullRepresentation

    Component.onCompleted: {
        switchState = (plasmoid.configuration.startupState === 0)
            if (plasmoid.configuration.executeCommandOnStartup) {
                executeCommand(switchState, false)
            }
            if (plasmoid.configuration.watcherEnabled) {
                watcherTimer.start()
            }
            if (plasmoid.configuration.autoOffRepeat > 0) {
                scheduleTimer.start()
            }
    }

    function buildRelayCommand(state) {
        if (plasmoid.configuration.relayMode === 1) {
            var count = plasmoid.configuration.relayCount || 1
            var onMask = (plasmoid.configuration.relayOnMask === undefined) ? 1 : plasmoid.configuration.relayOnMask
            var enMask = (plasmoid.configuration.relayEnabledMask === undefined) ? 1 : plasmoid.configuration.relayEnabledMask
            var cmds = []
            for (var i = 0; i < count; i++) {
                var bit = (1 << i)
                if ((enMask & bit) === 0) continue
                    var isOn = (onMask & bit) !== 0
                    var sendOn = isOn ? state : !state
                    cmds.push("echo " + (sendOn ? "1" : "0") + " > " + plasmoid.configuration.relayDevice)
            }
            return cmds.join(" && ")
        }

        if (plasmoid.configuration.relayControlMode === 1) {
            var b1 = state ? plasmoid.configuration.relayByte1On : plasmoid.configuration.relayByte1Off
            var b2 = state ? plasmoid.configuration.relayByte2On : plasmoid.configuration.relayByte2Off
            var b3 = state ? plasmoid.configuration.relayByte3On : plasmoid.configuration.relayByte3Off
            var b4 = state ? plasmoid.configuration.relayByte4On : plasmoid.configuration.relayByte4Off
            return "echo -en '\\x" + b1 + "\\x" + b2 + "\\x" + b3 + "\\x" + b4 + "' > " + plasmoid.configuration.relayDevice
        }

        if (plasmoid.configuration.relayControlMode === 2) {
            var rCount = plasmoid.configuration.relayCount || 1
            var advCmds = []
            var dataStr = plasmoid.configuration.relayAdvDataString || ""
            var lookupMap = {}
            if (dataStr !== "") {
                var tokens = dataStr.split(";")
                for (var j = 0; j < tokens.length; j++) {
                    if (!tokens[j]) continue
                        var pair = tokens[j].split("=")
                        if (pair.length >= 2) {
                            lookupMap[pair[0]] = pair[1]
                        }
                }
            }

            for (var k = 1; k <= rCount; k++) {
                var tag = (state ? "On_" : "Off_") + k
                var val = lookupMap[tag]
                if (val === undefined || val === "") {
                    var ch = k.toString(16).toUpperCase().padStart(2, "0")
                    var st = state ? "01" : "00"
                    var sum = 0xA0 + k + (state ? 1 : 0)
                    var cs = (sum & 0xFF).toString(16).toUpperCase().padStart(2, "0")
                    val = "A0," + ch + "," + st + "," + cs
                }
                var parts = val.split(",")
                advCmds.push("echo -en '\\x" + parts[0] + "\\x" + parts[1] + "\\x" + parts[2] + "\\x" + parts[3] + "' > " + plasmoid.configuration.relayDevice)
            }
            return advCmds.join(" && ")
        }

        var defCount = plasmoid.configuration.relayCount || 1
        var defOnMask = (plasmoid.configuration.relayOnMask === undefined) ? 1 : plasmoid.configuration.relayOnMask
        var defEnMask = (plasmoid.configuration.relayEnabledMask === undefined) ? 1 : plasmoid.configuration.relayEnabledMask
        var defCmds = []
        for (var m = 0; m < defCount; m++) {
            var dBit = (1 << m)
            if ((defEnMask & dBit) === 0) continue
                var dIsOn = (defOnMask & dBit) !== 0
                var dSt = (dIsOn === state) ? "01" : "00"
                var dCh = (m + 1).toString(16).toUpperCase().padStart(2, "0")
                var dSum = 0xA0 + (m + 1) + (dSt === "01" ? 1 : 0)
                var dCs = (dSum & 0xFF).toString(16).toUpperCase().padStart(2, "0")
                defCmds.push("echo -en '\\xA0\\x" + dCh + "\\x" + dSt + "\\x" + dCs + "' > " + plasmoid.configuration.relayDevice)
        }
        return defCmds.join(" && ")
    }

    function executeCommand(newState, isTimerTrigger) {
        var cmd = ""
        if (isTimerTrigger && plasmoid.configuration.customTimerCommandEnabled) {
            cmd = newState ? plasmoid.configuration.customTimerOnCommand : plasmoid.configuration.customTimerOffCommand
        } else if (plasmoid.configuration.relayEnabled) {
            cmd = buildRelayCommand(newState)
        } else {
            cmd = newState ? plasmoid.configuration.commandOn : plasmoid.configuration.commandOff
        }

        if (cmd && cmd.trim() !== "") {
            executionType = 0
            executable.exec(cmd, 0)
        }

        if (newState && plasmoid.configuration.autoOffEnabled) {
            countdownOffTimer.interval = plasmoid.configuration.autoOffDuration * 60 * 1000
            countdownOffTimer.restart()
        }
        if (!newState && plasmoid.configuration.autoOnEnabled) {
            countdownOnTimer.interval = plasmoid.configuration.autoOnDuration * 60 * 1000
            countdownOnTimer.restart()
        }
    }

    function executeScheduledTask() {
        var actionType = plasmoid.configuration.autoOffRepeatState
        if (actionType === 0) {
            switchState = false
                executeCommand(false, false)
        } else if (actionType === 1) {
            switchState = true
                executeCommand(true, false)
        } else if (actionType === 2) {
            if (plasmoid.configuration.customScheduleCommand.trim() !== "") {
                executionType = 0
                executable.exec(plasmoid.configuration.customScheduleCommand, 0)
            }
        }
    }

    function isTransparent(c) { return c === "transparent" || c === "" }
    function getFontWeight() { var w = plasmoid.configuration.fontWeight; return w === 1 ? Font.Bold : (w === 2 ? Font.Light : (w === 3 ? Font.Black : Font.Normal)) }
    function getFontFamily() { var f = plasmoid.configuration.fontFamily; return (f && f.trim() !== "") ? f : "" }
    function getTrackRadius() { var r = plasmoid.configuration.trackRadius; return r > 0 ? r : plasmoid.configuration.trackHeight / 2 }
    function getBallRadius() { var r = plasmoid.configuration.ballRadius; return r > 0 ? r : plasmoid.configuration.ballSize / 2 }

    function getPreferredWidth() {
        if (plasmoid.configuration.buttonStyle === 1) return plasmoid.configuration.buttonWidth > 0 ? plasmoid.configuration.buttonWidth : 100
            if (plasmoid.configuration.buttonStyle === 2) return plasmoid.configuration.trackHeight + (dummyTextMetric.implicitWidth + 16)
                return Math.max(plasmoid.configuration.trackWidth + 16, dummyTextMetric.implicitWidth + 10)
    }

    function getPreferredHeight() {
        var textHeight = dummyTextMetric.implicitHeight + (plasmoid.configuration.fontPadding || 2)
        if (plasmoid.configuration.buttonStyle === 1) return plasmoid.configuration.buttonHeight > 0 ? plasmoid.configuration.buttonHeight : 40
            if (plasmoid.configuration.buttonStyle === 2) return Math.max(plasmoid.configuration.trackHeight, textHeight) + 10
                if (plasmoid.configuration.buttonStyle === 3) return plasmoid.configuration.trackWidth + textHeight + 10
                    return plasmoid.configuration.trackHeight + textHeight + 20
    }

    function getPowerIconScale() { return plasmoid.configuration.powerBorderVisible ? 0.6 : 0.85 }
    function getPowerIconSize() { var scale = getPowerIconScale(); var pad = (plasmoid.configuration.powerImagePadding || 0) * 2; var base = plasmoid.configuration.trackWidth * ((plasmoid.configuration.powerIconSize || 50) / 50) * scale; return Math.max(10, Math.min(base, plasmoid.configuration.trackWidth) - pad) }

    Text { id: dummyTextMetric; visible: false; text: plasmoid.configuration.labelText || "Switch"; font.pixelSize: plasmoid.configuration.fontSize > 0 ? plasmoid.configuration.fontSize : 12; font.family: getFontFamily(); font.weight: getFontWeight(); font.letterSpacing: plasmoid.configuration.fontLetterSpacing }

    Timer {
        id: watcherTimer
        interval: plasmoid.configuration.watcherInterval * 1000
        running: false
        repeat: true
        onTriggered: {
            if (plasmoid.configuration.watcherCommand.trim() !== "") {
                executionType = 2
                executable.exec(plasmoid.configuration.watcherCommand, 2)
            }
        }
    }

    Timer {
        id: countdownOffTimer
        running: false
        repeat: false
        onTriggered: {
            switchState = false
                executeCommand(false, true)
        }
    }

    Timer {
        id: countdownOnTimer
        running: false
        repeat: false
        onTriggered: {
            switchState = true
                executeCommand(true, true)
        }
    }

    Timer {
        id: scheduleTimer
        interval: 60000
        running: false
        repeat: true
        onTriggered: {
            var repeatType = plasmoid.configuration.autoOffRepeat
            if (repeatType === 0) {
                return
            }

            var now = new Date()
            if (now.getHours() === plasmoid.configuration.autoOffHour && now.getMinutes() === plasmoid.configuration.autoOffMinute) {
                var dayIdx = now.getDay()
                var isoDay = (dayIdx === 0) ? 6 : dayIdx - 1
                var shouldTrigger = false

                if (repeatType === 1) {
                    shouldTrigger = true
                } else if (repeatType === 2 && isoDay === 0) {
                    shouldTrigger = true
                } else if (repeatType === 3 && isoDay >= 0 && isoDay <= 4) {
                    shouldTrigger = true
                } else if (repeatType === 4 && (isoDay === 5 || isoDay === 6)) {
                    shouldTrigger = true
                } else if (repeatType === 5) {
                    var bitmaskText = plasmoid.configuration.relayScheduleDaysActive || "0,0,0,0,0,0,0"
                    var activeDays = bitmaskText.split(",")
                    if (activeDays[isoDay] === "1") {
                        shouldTrigger = true
                    }
                }

                if (shouldTrigger) {
                    executeScheduledTask()
                }
            }
        }
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName, data) {
            var exitCode = data["exit code"]
            disconnectSource(sourceName)
            if (executionType === 2) {
                switchState = (exitCode === 0)
            }
            executionType = 0
        }
        function exec(cmd, type) {
            if (!cmd || cmd.trim() === "") {
                return
            }
            executionType = type
            connectSource(cmd)
        }
    }

    toolTipMainText: plasmoid.configuration.tooltipText || "Custom Switch"
    toolTipSubText: plasmoid.configuration.labelText || "Switch"

    fullRepresentation: Item {
        Layout.preferredWidth: getPreferredWidth()
        Layout.preferredHeight: getPreferredHeight()
        Layout.leftMargin: 0
        Layout.rightMargin: 0
        Layout.topMargin: 0
        Layout.bottomMargin: 0

        Rectangle {
            id: buttonBg
            anchors.fill: parent
            radius: plasmoid.configuration.buttonBgRadius
            color: isTransparent(plasmoid.configuration.buttonBgColor) ? "transparent" : plasmoid.configuration.buttonBgColor
            border.color: isTransparent(plasmoid.configuration.buttonBorderColor) ? "transparent" : plasmoid.configuration.buttonBorderColor
            border.width: plasmoid.configuration.buttonBorderWidth
            opacity: plasmoid.configuration.backgroundOpacity / 100
        }

        Item {
            id: switchStyle
            anchors.centerIn: parent
            visible: plasmoid.configuration.buttonStyle === 0
            width: plasmoid.configuration.trackWidth
            height: plasmoid.configuration.trackHeight + dummyTextMetric.implicitHeight + (plasmoid.configuration.fontPadding || 2) + 4

            Rectangle {
                id: track
                width: plasmoid.configuration.trackWidth
                height: plasmoid.configuration.trackHeight
                radius: getTrackRadius()
                color: switchState ? plasmoid.configuration.colorOn : plasmoid.configuration.colorOff
                border.color: switchState ? plasmoid.configuration.borderColorOn : plasmoid.configuration.borderColorOff
                border.width: plasmoid.configuration.borderWidth
                anchors.horizontalCenter: parent.horizontalCenter
                y: plasmoid.configuration.fontPosition === 0 ? (dummyTextMetric.implicitHeight + (plasmoid.configuration.fontPadding || 2)) : 0

                Rectangle {
                    width: plasmoid.configuration.ballSize
                    height: plasmoid.configuration.ballSize
                    radius: getBallRadius()
                    color: plasmoid.configuration.ballColor
                    border.color: plasmoid.configuration.ballBorderColor
                    border.width: plasmoid.configuration.ballBorderWidth
                    y: (track.height - height) / 2
                    x: switchState ? (track.width - width - 1) : 1
                    Behavior on x { SpringAnimation { spring: 3; damping: 0.25 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        switchState = !switchState
                            executeCommand(switchState, false)
                    }
                }
            }

            Text {
                text: plasmoid.configuration.labelText || "Switch"
                color: switchState ? plasmoid.configuration.textColorOn : plasmoid.configuration.textColorOff
                font.pixelSize: plasmoid.configuration.fontSize > 0 ? plasmoid.configuration.fontSize : 12
                font.family: getFontFamily()
                font.weight: getFontWeight()
                font.letterSpacing: plasmoid.configuration.fontLetterSpacing
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: track.bottom
                    topMargin: plasmoid.configuration.fontPadding || 2
                }
                visible: plasmoid.configuration.fontPosition === 1
            }

            Text {
                text: plasmoid.configuration.labelText || "Switch"
                color: switchState ? plasmoid.configuration.textColorOn : plasmoid.configuration.textColorOff
                font.pixelSize: plasmoid.configuration.fontSize > 0 ? plasmoid.configuration.fontSize : 12
                font.family: getFontFamily()
                font.weight: getFontWeight()
                font.letterSpacing: plasmoid.configuration.fontLetterSpacing
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: track.top
                    bottomMargin: plasmoid.configuration.fontPadding || 2
                }
                visible: plasmoid.configuration.fontPosition === 0
            }
        }

        Item {
            id: buttonStyle
            anchors.centerIn: parent
            visible: plasmoid.configuration.buttonStyle === 1
            width: plasmoid.configuration.buttonWidth > 0 ? plasmoid.configuration.buttonWidth : 100
            height: plasmoid.configuration.buttonHeight > 0 ? plasmoid.configuration.buttonHeight : 40

            Rectangle {
                anchors.fill: parent
                radius: plasmoid.configuration.buttonBgRadius
                color: switchState ? plasmoid.configuration.colorOn : plasmoid.configuration.colorOff
                border.color: switchState ? plasmoid.configuration.borderColorOn : plasmoid.configuration.borderColorOff
                border.width: plasmoid.configuration.borderWidth

                Text {
                    anchors.centerIn: parent
                    text: plasmoid.configuration.labelText || "Switch"
                    color: switchState ? plasmoid.configuration.textColorOn : plasmoid.configuration.textColorOff
                    font.pixelSize: plasmoid.configuration.fontSize > 0 ? plasmoid.configuration.fontSize : 12
                    font.family: getFontFamily()
                    font.weight: getFontWeight()
                    font.letterSpacing: plasmoid.configuration.fontLetterSpacing
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        switchState = !switchState
                            executeCommand(switchState, false)
                    }
                }
            }
        }

        Item {
            id: checkboxStyle
            anchors.centerIn: parent
            visible: plasmoid.configuration.buttonStyle === 2
            width: parent.width
            height: Math.max(plasmoid.configuration.trackHeight, dummyTextMetric.implicitHeight)

            Rectangle {
                id: checkBox
                width: plasmoid.configuration.trackHeight
                height: plasmoid.configuration.trackHeight
                radius: Math.min(plasmoid.configuration.buttonBgRadius, plasmoid.configuration.trackHeight / 2)
                color: switchState ? plasmoid.configuration.colorOn : "transparent"
                border.color: switchState ? plasmoid.configuration.borderColorOn : plasmoid.configuration.borderColorOff
                border.width: plasmoid.configuration.borderWidth
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }

                Text {
                    anchors.centerIn: parent
                    text: "\u2713"
                    color: "white"
                    font.pixelSize: plasmoid.configuration.trackHeight * 0.6
                    visible: switchState
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        switchState = !switchState
                            executeCommand(switchState, false)
                    }
                }
            }

            Text {
                text: plasmoid.configuration.labelText || "Switch"
                color: switchState ? plasmoid.configuration.textColorOn : plasmoid.configuration.textColorOff
                font.pixelSize: plasmoid.configuration.fontSize > 0 ? plasmoid.configuration.fontSize : 12
                font.family: getFontFamily()
                font.weight: getFontWeight()
                font.letterSpacing: plasmoid.configuration.fontLetterSpacing
                anchors {
                    left: checkBox.right
                    leftMargin: 6
                    verticalCenter: checkBox.verticalCenter
                }
            }
        }

        Item {
            id: powerStyle
            anchors.centerIn: parent
            visible: plasmoid.configuration.buttonStyle === 3
            width: plasmoid.configuration.trackWidth
            height: plasmoid.configuration.trackWidth + dummyTextMetric.implicitHeight + (plasmoid.configuration.powerLabelSpacing || 2) + 4

            Item {
                id: powerIcon
                width: Math.min(plasmoid.configuration.trackWidth * ((plasmoid.configuration.powerIconSize || 50) / 50), parent.width)
                height: Math.min(plasmoid.configuration.trackWidth * ((plasmoid.configuration.powerIconSize || 50) / 50), parent.width)
                anchors.horizontalCenter: parent.horizontalCenter
                y: plasmoid.configuration.fontPosition === 0 ? (dummyTextMetric.implicitHeight + (plasmoid.configuration.powerLabelSpacing || 2)) : 0

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width * 0.85
                    height: parent.height * 0.85
                    radius: plasmoid.configuration.powerShape === 1 ? parent.width * 0.17 : parent.width / 2
                    color: "transparent"
                    border.color: switchState ? plasmoid.configuration.colorOn : plasmoid.configuration.colorOff
                    border.width: Math.max(2, plasmoid.configuration.borderWidth + 1)
                    visible: plasmoid.configuration.powerBorderVisible
                }

                Item {
                    anchors.centerIn: parent
                    width: getPowerIconSize()
                    height: getPowerIconSize()
                    visible: plasmoid.configuration.powerIconOn === "" && plasmoid.configuration.powerIconOff === ""

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        radius: width / 2
                        color: "transparent"
                        border.color: switchState ? plasmoid.configuration.colorOn : plasmoid.configuration.colorOff
                        border.width: Math.max(2, plasmoid.configuration.borderWidth + 1)
                    }

                    Rectangle {
                        width: Math.max(2, plasmoid.configuration.borderWidth + 1)
                        height: parent.height * 0.55
                        x: (parent.width - width) / 2
                        y: 0
                        color: switchState ? plasmoid.configuration.colorOn : plasmoid.configuration.colorOff
                        radius: width / 2
                    }
                }

                Image {
                    anchors.centerIn: parent
                    visible: switchState && plasmoid.configuration.powerIconOn !== ""
                    source: (plasmoid.configuration.powerIconOn || "").trim().indexOf("file:///") === 0 ? (plasmoid.configuration.powerIconOn || "").trim() : "file://" + (plasmoid.configuration.powerIconOn || "").trim()
                    width: getPowerIconSize()
                    height: getPowerIconSize()
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                Image {
                    anchors.centerIn: parent
                    visible: !switchState && plasmoid.configuration.powerIconOff !== ""
                    source: (plasmoid.configuration.powerIconOff || "").trim().indexOf("file:///") === 0 ? (plasmoid.configuration.powerIconOff || "").trim() : "file://" + (plasmoid.configuration.powerIconOff || "").trim()
                    width: getPowerIconSize()
                    height: getPowerIconSize()
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        switchState = !switchState
                            executeCommand(switchState, false)
                    }
                }
            }

            Text {
                text: plasmoid.configuration.labelText || "Switch"
                color: switchState ? plasmoid.configuration.textColorOn : plasmoid.configuration.textColorOff
                font.pixelSize: plasmoid.configuration.fontSize > 0 ? plasmoid.configuration.fontSize : 12
                font.family: getFontFamily()
                font.weight: getFontWeight()
                font.letterSpacing: plasmoid.configuration.fontLetterSpacing
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: powerIcon.bottom
                    topMargin: plasmoid.configuration.powerLabelSpacing
                }
                visible: plasmoid.configuration.fontPosition === 1
            }

            Text {
                text: plasmoid.configuration.labelText || "Switch"
                color: switchState ? plasmoid.configuration.textColorOn : plasmoid.configuration.textColorOff
                font.pixelSize: plasmoid.configuration.fontSize > 0 ? plasmoid.configuration.fontSize : 12
                font.family: getFontFamily()
                font.weight: getFontWeight()
                font.letterSpacing: plasmoid.configuration.fontLetterSpacing
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: powerIcon.top
                    bottomMargin: plasmoid.configuration.powerLabelSpacing
                }
                visible: plasmoid.configuration.fontPosition === 0
            }
        }
    }
}
