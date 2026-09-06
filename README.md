# 🖲️ KDE Plasma Custom Switch and Relay Control v2

A simple, fully customizable On/Off switch for your KDE Plasma 6 desktop. This widget lets you flip a switch right on your desktop or taskbar to run terminal commands, control background programs, or toggle real-world electronics. 

Inspired by and expanded from the Intika On/Off Switch and alduccino On/Off Switch widgets.

- **Fork Source:** [alduccino/on-off-switch-plasmoid](https://github.com)
- **Original Source:** [Intika-KDE-Plasmoids/plasmoid-on-off-switch-commands](https://github.com)

---

## ✨ Features

- **Run Any Command:** Type in a command to run when the switch turns ON, and another for when it turns OFF.
- **Timer & Auto-Loop:** Set the switch to turn itself off (or back on) automatically after a few minutes. You can even set it to loop back and forth.
- **Day & Time Scheduler:** Schedule the switch to force itself ON or OFF at a specific time on chosen days of the week (like every weekday at 8:00 AM).
- **USB Relay Control:** Built-in support for USB relay boards (CH340/HID modules). This lets the desktop switch directly trigger real-world electronic circuits and smart hardware.
- **Live Status Watcher:** Set the switch to look at a file or check a background setting so it always shows your computer's true live status.
- **Smart Startup:** Choose whether the switch defaults to ON or OFF every time you boot up your computer.

---

## 🎨 Design Options

- **4 Different Styles:** Change the look instantly between a sliding **Toggle Switch**, a regular **Push Button**, a **Checkbox**, or a round **Power Button**.
- **Custom Icons:** Don't like the default look? Type in the path to your own PNG or SVG picture to use it as the button icon.
- **Auto-Sizing:** The widget automatically scales so your text never gets clipped or cut off, no matter what font size you choose.
- **Color & Opacity:** Full control over text colors, borders, background colors, and transparency for every single switch state.

---

## 🧰 How to Install

### Method 1: For CachyOS / Arch Linux (Recommended Package Build)
If you are on an Arch Linux-based system like CachyOS, you can easily install and manage the widget securely through your package manager:

```bash
git clone https://github.com
cd customswitchrelaycontrol
makepkg -si
```

### Method 2: Manual Installation (Any Linux Distribution)
```bash
git clone https://github.com
cd customswitchrelaycontrol
kpackagetool6 --type Plasma/Applet --install .
```
*(Note: Use `kpackagetool5` instead if you are using an older version of the desktop).*

#### ⚠️ Important: Restart Your Desktop to Finish
After installing, restart your desktop panel so the new switch settings show up correctly. Run this clean systemd command in your terminal:
```bash
systemctl --user restart plasma-plasmashell
```

---

## 🔧 Fix USB Hardware Permissions (For Relay Board Users)

By default, Arch Linux and CachyOS block regular users from accessing raw USB port hardware directly (like `/dev/ttyUSB0`). If you are using a USB relay board, **you must grant your user account access to the serial group, or your switch clicks will do nothing.**

Open your terminal and run this single security command:
```bash
sudo usermod -aG uucp \$USER
```
*Note: Log out of your desktop session completely and log back in to apply the group permissions!*

---

## 🗑️ How to Uninstall

To completely remove the widget and clear all of its saved settings from your computer, run these commands:

```bash
kpackagetool6 --type Plasma/Applet --remove org.kde.plasma.customswitchrelaycontrol
rm -rf ~/.local/share/plasma/plasmoids/org.kde.plasma.customswitchrelaycontrol
systemctl --user restart plasma-plasmashell
```

---

## 🖥️ How to Add the Switch to Your Desktop

1. Right-click an empty space on your desktop or taskbar panel.
2. Click **"Add Widgets..."** to open your widget menu.
3. Search for **"Custom Switch Relay Control v2"**.
4. Drag and drop it exactly where you want it to live!

---

## 🧑‍💻 Example Ideas (What can you do with it?)

| What you want to do | Command ON | Command OFF |
| :--- | :--- | :--- |
| **Turn Wi-Fi On/Off** | `nmcli radio wifi on` | `nmcli radio wifi off` |
| **Turn Bluetooth On/Off** | `rfkill unblock bluetooth` | `rfkill block bluetooth` |
| **Mount a backup drive** | `mount /mnt/data` | `umount /mnt/data` |
| **Turn on dark mode** | `plasma-apply-colorscheme BreezeDark` | `plasma-apply-colorscheme BreezeLight` |

---

*Built with help and assistance of AI.*
