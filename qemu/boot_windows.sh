#!/bin/bash

qemu-system-x86_64 \
    -machine q35 \
    -cpu host,kvm=off,topoext,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
    -enable-kvm \
    -m 8G \
    -mem-prealloc \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/ovmf/x64/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file=/usr/share/ovmf/x64/OVMF_VARS.fd \
    -smp 10,sockets=1,cores=5,threads=2 \
    -drive file=/dev/nvme0n1,media=disk,format=raw,cache=none \
    -drive file=/dev/nvme1n1p2,media=disk,format=raw,cache=none,if=virtio \
    -cdrom virtio-win-0.1.240.iso \
    -nic user,id=nic0,smb=/home/nekoconn/,model=virtio-net-pci \
    -vga none \
    -nographic \
    -device vfio-pci,multifunction=on,host=01:00.0 \
    -device vfio-pci,host=01:00.1 \
    -rtc base=localtime,clock=host\
    -audiodev pa,id=audio0,timer-period=100 \
    -device ich9-intel-hda \
    -device hda-micro,audiodev=audio0 \
    -device ivshmem-plain,memdev=ivshmem,bus=pcie.0 \
    -object memory-backend-file,id=ivshmem,share=on,mem-path=/dev/shm/looking-glass,size=32M \
    -usbdevice mouse \
    -usbdevice keyboard \
    -spice port=5900,addr=127.0.0.1,disable-ticketing=on
    # -virtfs local,path=/dev/nvme1n1p2,mount_tag=NewVolume,security_model=mapped-xattr \
