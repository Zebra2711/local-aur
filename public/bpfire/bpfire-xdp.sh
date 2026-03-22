#!/bin/bash
# BPFire XDP SYNPROXY control script

IFACE="${BPFIRE_IFACE:-eth0}"
XDP_PROG="/usr/lib/bpfire-xdp/xdp_synproxy.o"

start() {
    echo "[+] Loading BPFire XDP SYNPROXY on $IFACE..."
    xdp-loader load "$IFACE" "$XDP_PROG"
    if [ $? -eq 0 ]; then
        echo "[+] XDP SYNPROXY loaded"
        echo "[+] Enabling SYNPROXY via nftables..."
        nft add table inet bpfire 2>/dev/null
        nft add chain inet bpfire syn_flood { type filter hook prerouting priority -150\; } 2>/dev/null
        nft add rule inet bpfire syn_flood tcp flags syn counter
        echo "[+] BPFire XDP defense active"
    else
        echo "[!] Failed to load XDP program"
        exit 1
    fi
}

stop() {
    echo "[-] Unloading BPFire XDP SYNPROXY from $IFACE..."
    xdp-loader unload --all "$IFACE"
    nft delete table inet bpfire 2>/dev/null
    echo "[-] BPFire XDP defense removed"
}

status() {
    echo "--- BPFire XDP Status ---"
    xdp-loader status "$IFACE"
}

case "$1" in
    start)  start  ;;
    stop)   stop   ;;
    status) status ;;
    *)
        echo "Usage: bpfire-xdp {start|stop|status}"
        echo "Set interface via: export BPFIRE_IFACE=wlan0"
        exit 1
        ;;
esac
