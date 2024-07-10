#!/bin/bash

qemu-system-x86_64 \
    -bios /usr/share/ovmf/x64/OVMF_CODE.fd \
    -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
    -enable-kvm -m 9G -smp 10 --enable-kvm \
    -drive file=/dev/nvme0n1,media=disk,format=raw,if=virtio,cache=none \
    -cdrom virtio-win-0.1.240.iso \
    -nic user,id=nic0,smb=/home/nekoconn/,model=virtio-net-pci \
    -vga virtio \
    -audiodev pa,id=snd0 \
    -device ich9-intel-hda \
    -device hda-output,audiodev=snd0
