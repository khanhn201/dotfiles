#!/bin/sh
# QEMU's slirp SMB server (-nic ...,smb=...) only forks smbd on-demand, once
# the guest actually makes its first SMB connection -- so this waits for
# that to happen, then patches in wide-symlink support and reloads.
#
# Deliberately does NOT set "force user": QEMU already generates the temp
# config with "force user=<you>" (matching the account running qemu), and
# smbd itself runs unprivileged as that same user, so it cannot setuid to
# anything else. Forcing "force user=root" here silently overrides QEMU's
# correct default (later config wins) and every request then fails, because
# a non-root smbd can't become root.

for i in $(seq 1 120); do
    eval $(ps h -C smbd -o pid,args | grep /tmp/qemu-smb | gawk '{print "pid="$1";conf="$6}')
    [ -n "$pid" ] && break
    sleep 1
done

if [ -z "$pid" ]; then
    echo "modify_smb: timed out waiting for qemu's smbd to start (did the guest try to connect to \\\\10.0.2.4\\qemu yet?)" >&2
    exit 1
fi

echo "[global]
allow insecure wide links = yes
[qemu]
follow symlinks = yes
wide links = yes
acl allow execute always = yes" >> "$conf"

smbcontrol --configfile="$conf" "$pid" reload-config
