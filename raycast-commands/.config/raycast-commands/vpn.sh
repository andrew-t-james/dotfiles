#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title vpn
# @raycast.mode fullOutput
# @raycast.argument1 { "type": "text", "placeholder": "on / off" }

case "$#" in
    0)
        echo "Usage: vpnc [on|off]" 1>&2
    ;;
    *)
        cmd="$1";
        case "$cmd" in
            on)
                ${HOME}/.config/vpn-connect.sh
            ;;
            off)
                /opt/cisco/anyconnect/bin/vpn disconnect
            ;;
            *)
                echo "Usage: vpnc [on|off]" 1>&2
            ;;
        esac
    ;;
esac

