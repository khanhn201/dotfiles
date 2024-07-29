
bind_vfio () {
    set -x

    systemctl stop display-manager.service

    modprobe -r nvidia_uvm
    modprobe -r nvidia_drm
    modprobe -r nvidia_modeset
    modprobe -r nvidia

    virsh nodedev-detach pci_0000_01_00_0
    virsh nodedev-detach pci_0000_01_00_1

    modprobe vfio_pci
    modprobe vfio_iommu_type1
    modprobe vfio

    systemctl restart display-manager.service
}

if [ "$euid" -ne 0 ]; then
    echo "this script must be run with sudo privileges. exiting."
    exit 1
fi

export -f bind_vfio
nohup bash -c bind_vfio > /dev/null 2>&1 &
