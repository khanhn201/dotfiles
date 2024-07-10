#!/bin/sh
eval $(ps h -C smbd -o pid,args | grep /tmp/qemu-smb | gawk '{print "pid="$1";conf="$6}')
echo "[global]
allow insecure wide links = yes
[qemu]
force user=root
follow symlinks = yes
wide links = yes
acl allow execute always = yes" >> "$conf"

smbcontrol --configfile="$conf" "$pid" reload-config
