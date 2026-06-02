#!/bin/sh

# pfSense starts package rc scripts from /usr/local/etc/rc.d/*.sh.
# The FreeBSD ZeroTier rc script is named "zerotier", so this wrapper bridges it.

enabled=$(/usr/sbin/sysrc -n zerotier_enable 2>/dev/null || echo NO)

case "$1" in
    start|restart|onestart|onerestart)
        case "$enabled" in
            YES|yes|Yes|TRUE|true|True|1)
                if /usr/sbin/service zerotier onestatus >/dev/null 2>&1; then
                    exit 0
                fi
                /usr/sbin/service zerotier onestart
                ;;
        esac
        ;;
    stop|onestop)
        /usr/sbin/service zerotier onestop
        ;;
    *)
        /usr/sbin/service zerotier "$@"
        ;;
esac

