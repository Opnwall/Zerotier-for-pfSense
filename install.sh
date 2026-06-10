#!/bin/sh

set -e

printf '\n'
printf '\033[32m============ ZeroTier for pfSense installer ==============\033[0m\n'
printf '\n'

GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

ROOT="/usr/local"
WWW_DIR="$ROOT/www"
PKG_DIR="$ROOT/pkg"
MENU_DIR="$ROOT/share/pfSense/menu"
SCRIPT_DIR=$(CDPATH='' cd "$(dirname "$0")" && pwd)
PROJECT_ROOT="$SCRIPT_DIR"
SRC_ROOT="$PROJECT_ROOT/src/usr/local"

log() {
    color="$1"
    message="$2"
    printf '%b%s%b\n' "$color" "$message" "$RESET"
}

if [ "$(id -u)" -ne 0 ]; then
    log "$RED" "Please run this installer as root."
    exit 1
fi

detect_freebsd_major_version() {
    version=$(freebsd-version -u 2>/dev/null || freebsd-version 2>/dev/null || uname -r)
    version=${version%%-*}
    version=${version%%.*}

    if [ -z "$version" ] || ! printf '%s' "$version" | grep -Eq '^[0-9]+$'; then
        return 1
    fi

    printf '%s\n' "$version"
}

log "$YELLOW" "Detecting FreeBSD version..."
FREEBSD_MAJOR=$(detect_freebsd_major_version) || {
    log "$RED" "Unable to detect the FreeBSD major version used by pfSense."
    exit 1
}
log "$GREEN" "Detected FreeBSD ${FREEBSD_MAJOR}."

set -- "$SRC_ROOT"/bin/zerotier-*-freebsd"${FREEBSD_MAJOR}".pkg
if [ ! -f "$1" ]; then
    log "$RED" "No ZeroTier package was found for FreeBSD ${FREEBSD_MAJOR}."
        log "$YELLOW" "Please make sure src/usr/local/bin/ contains zerotier-*-freebsd${FREEBSD_MAJOR}.pkg."
    exit 1
fi
ZEROTIER_PKG="$1"

log "$YELLOW" "Installing ZeroTier: $(basename "$ZEROTIER_PKG")"
pkg add -f "$ZEROTIER_PKG"
printf '\n'

log "$YELLOW" "Copying files..."

log "$YELLOW" "Installing menu entry..."
mkdir -p "$WWW_DIR" "$PKG_DIR" "$MENU_DIR" "$ROOT/etc/rc.d"
cp -f "$SRC_ROOT"/www/* "$WWW_DIR/"
cp -f "$SRC_ROOT"/pkg/* "$PKG_DIR/"
cp -R "$SRC_ROOT"/share/pfSense/menu/* "$MENU_DIR/"

log "$YELLOW" "Leaving ZeroTier disabled until it is enabled in the WebGUI..."
sysrc -q zerotier_enable=NO >/dev/null 2>&1 || \
    log "$YELLOW" "Unable to set zerotier_enable=NO. Please enable ZeroTier from the WebGUI after installation."
cp -f "$SRC_ROOT/etc/rc.d/zerotier.sh" "$ROOT/etc/rc.d/zerotier.sh"
chmod 755 "$ROOT/etc/rc.d/zerotier.sh"
printf '\n'

log "$YELLOW" "Configuring tunables..."
if ! grep -Eq '^[[:space:]]*net\.link\.tap\.up_on_open[[:space:]]*=' /etc/sysctl.conf 2>/dev/null; then
    printf '\n# Required for ZeroTier TAP interfaces during pfSense startup.\nnet.link.tap.up_on_open=1\n' >> /etc/sysctl.conf
fi
sysctl net.link.tap.up_on_open=1 >/dev/null 2>&1 || \
    log "$YELLOW" "The sysctl setting was written to /etc/sysctl.conf and will take effect after TAP support is loaded."

log "$YELLOW" "Installation completed."
printf '\n'
log "$YELLOW" "Next steps..."

log "$GREEN" "1. Enable the service from VPN > ZeroTier VPN > Configuration."

log "$GREEN" "2. Join a ZeroTier network from the Networks page."

log "$GREEN" "3. Authorize this node in the ZeroTier Central console."

log "$GREEN" "4. Use VPN > Zerotier for additional operations."
printf '\n'
