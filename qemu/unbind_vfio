unbind_vfio () {
    set -x

    modprobe -r vfio_pci
    modprobe -r vfio_iommu_type1
    modprobe -r vfio

    virsh nodedev-reattach pci_0000_01_00_0
    virsh nodedev-reattach pci_0000_01_00_1

    modprobe nvidia_uvm
    modprobe nvidia_drm
    modprobe nvidia_modeset
    modprobe nvidia

    systemctl restart display-manager.service
}

if [ "$euid" -ne 0 ]; then
    echo "this script must be run with sudo privileges. exiting."
    exit 1
fi

export -f unbind_vfio
nohup bash -c unbind_vfio > /dev/null 2>&1 &
