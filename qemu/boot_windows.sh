#!/bin/bash

sudo qemu-system-x86_64 \
    -bios /usr/share/ovmf/x64/OVMF_CODE.fd \
    -cpu host -enable-kvm -m 8G -smp 8 --enable-kvm \
    -drive file=/dev/nvme0n1,media=disk,format=raw \
    -nic user,id=nic0,smb=/home/nekoconn/ \
    -audio pa
