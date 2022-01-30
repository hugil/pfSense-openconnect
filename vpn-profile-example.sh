#!/bin/sh

# settings
user="YourUsername"
pass="YourPassword"
host="vpnhost.company.com"
test="nc -v -w 10 -z testclient.company.com 3389"
iface="tun1001"
pidfile="/tmp/${iface}.pid"
script="/usr/local/sbin/vpnc-script"


# env
openconnect="/usr/local/sbin/openconnect"
ifconfig="/sbin/ifconfig"


# func
ifkill()
{
        $ifconfig "$1" down 2>/dev/null || :
        $ifconfig "$1" destroy 2>/dev/null || :
}


# check if we're already running
if [ -n "$test" ] && $test; then
        echo "Connection is already up"
        exit 0
fi

# clean up previous instance, if any
if [ -e "$pidfile" ]; then
        read pid <"$pidfile"
        echo "Killing previous pid: $pid"
        kill -TERM "$pid"
        rm "$pidfile"
fi
ifkill "$iface"


# open vpn connection
echo "$pass" |\
$openconnect \
        --certificate="certificate_if_needed.p12" \
        --useragent="Cisco AnyConnect VPN Agent for Windows 4.10.00093" \
        --protocol=anyconnect \
        --background \
        --pid-file="$pidfile" \
        --interface="$iface" \
        --user="$user" \
        --passwd-on-stdin \
        --script="$script" \
        # uncomment to troubleshoot: --verbose \
        "$host"


# rename the interface
if [ "$iface" != "$tmpif" ]; then
        echo "Renaming $tmpif to $iface"
        $ifconfig "$tmpif" name "$iface"
fi
