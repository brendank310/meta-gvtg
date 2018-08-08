DESCRIPTION = "Gvt-g Dom0 Image"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit gvtg-image

INITRD_IMAGE = "core-image-minimal"

do_bootimg[depends] += "dom0-gvtg-image-initramfs:do_image_complete"

IMAGE_INSTALL += " \
${@bb.utils.contains('MACHINE_FEATURES', 'acpi', 'kernel-module-xen-acpi-processor', '', d)} \
kernel-module-i915 \
kernel-module-xengt \
kernel-module-vfio-iommu-type1 \
kernel-module-vfio-mdev \
kernel-module-hid-alps \
kernel-image-bzimage \
kernel-module-efivarfs \
kernel-module-xen-blkback \
kernel-module-xen-gntalloc \
kernel-module-xen-gntdev \
kernel-module-xen-netback \
kernel-module-xen-wdt \
qemu \
pciutils \
coreutils \
usbutils \
plymouth \
xen-base \
xen-efi \
seabios \
ovmf \
xen-hypervisor \
grub-efi \
grub-bootconf \
weston \
weston-init \
kernel-modules \
"

#BAD_RECOMMENDATIONS += " xen-hvmloader "

image_postprocess_dom0() {
install -m 0644 ${DEPLOY_DIR_IMAGE}/dom0-gvtg-image-initramfs-${MACHINE}.cpio.gz ${IMAGE_ROOTFS}/boot/initramfs.gz
rm ${IMAGE_ROOTFS}/${systemd_unitdir}/system/xendomains.service
chmod 0755 ${IMAGE_ROOTFS}/${base_libdir}/systemd/systemd-vconsole-setup
chmod 0755 ${IMAGE_ROOTFS}/${base_libdir}/systemd/systemd-remount-fs
chmod 0755 ${IMAGE_ROOTFS}/${base_libdir}/systemd/systemd-random-seed
chmod 0755 ${IMAGE_ROOTFS}/${base_libdir}/systemd/systemd-machined
chmod 0755 ${IMAGE_ROOTFS}/${base_libdir}/systemd/systemd-timesyncd
}

IMAGE_ROOTFS_EXTRA_SPACE += " + 32768 "

ROOTFS_POSTPROCESS_COMMAND_append = " \
image_postprocess_dom0; \
"
