import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: "Commands"
        icon: "system-run"
        source: "configCommands.qml"
    }
    ConfigCategory {
        name: "USB Relay"
        icon: "usb-pd"
        source: "configRelay.qml"
    }
    ConfigCategory {
        name: "Style"
        icon: "preferences-desktop-theme"
        source: "configStyle.qml"
    }
    ConfigCategory {
        name: "Appearance"
        icon: "preferences-desktop-color"
        source: "configAppearance.qml"
    }
}
