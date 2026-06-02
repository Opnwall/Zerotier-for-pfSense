#!/bin/sh

set -e

printf '\n'
printf '\033[32m============ ZeroTier for pfSense uninstaller ==============\033[0m\n'
printf '\n'

GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

ROOT="/usr/local"
WWW_DIR="$ROOT/www"
PKG_DIR="$ROOT/pkg"
MENU_DIR="$ROOT/share/pfSense/menu"

log() {
    color="$1"
    message="$2"
    printf '%b%s%b\n' "$color" "$message" "$RESET"
}

remove_file() {
    file="$1"

    if [ -e "$file" ] || [ -L "$file" ]; then
        rm -f "$file"
        log "$GREEN" "Removed: $file"
    else
        log "$YELLOW" "File does not exist, skipped: $file"
    fi
}

if [ "$(id -u)" -ne 0 ]; then
    log "$RED" "Please run the uninstaller as root."
    exit 1
fi

log "$YELLOW" "Stopping ZeroTier service..."
if command -v service >/dev/null 2>&1; then
    service zerotier stop >/dev/null 2>&1 || true
fi
if command -v pkill >/dev/null 2>&1; then
    pkill -f zerotier-one >/dev/null 2>&1 || true
fi

log "$YELLOW" "Disabling ZeroTier auto-start..."
if command -v sysrc >/dev/null 2>&1; then
    sysrc -q -x zerotier_enable >/dev/null 2>&1 || true
fi

log "$YELLOW" "Removing ZeroTier package..."
if pkg info -e zerotier >/dev/null 2>&1; then
    pkg delete -y -f zerotier
else
    log "$YELLOW" "ZeroTier package not installed, skipped."
fi

log "$YELLOW" "Removing pfSense ZeroTier pages and configuration files..."
remove_file "$WWW_DIR/zerotier.php"
remove_file "$WWW_DIR/zerotier_networks.php"
remove_file "$WWW_DIR/zerotier_peers.php"
remove_file "$ROOT/etc/rc.d/zerotier.sh"
remove_file "$PKG_DIR/zerotier.inc"
remove_file "$PKG_DIR/zerotier.xml"
remove_file "$MENU_DIR/pfSense-VPN_ZeroTier.xml"

printf '\n'
log "$GREEN" "ZeroTier uninstallation completed."
printf '\n'
