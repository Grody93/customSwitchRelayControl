# Maintainer: Grody93 <https://github.com>
pkgname=plasma6-applet-customswitchrelaycontrol
pkgver=2.0.0
pkgrel=1
pkgdesc="On/Off switch for KDE Plasma 6 with loop timers, task scheduling, and USB relay controls"
arch=('any')
url="https://github.com"
license=('GPL-2.0-or-later')
depends=('plasma-workspace' 'qt6-declarative')
source=("git+${url}.git")
sha256sums=('SKIP')

package() {
  _dest="${pkgdir}/usr/share/plasma/plasmoids/org.kde.plasma.customswitchrelaycontrol"
  install -d "${_dest}"
  cp -r "${srcdir}/customswitchrelaycontrol"/* "${_dest}/"
}
