set -x

optimus-manager --no-confirm --switch integrated <<< "Y"
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
