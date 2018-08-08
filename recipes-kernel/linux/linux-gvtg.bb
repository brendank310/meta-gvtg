DEPENDS += "${@bb.utils.contains('ARCH', 'x86', 'elfutils-native', '', d)}"
DEPENDS += "openssl-native util-linux-native"

COMPATIBLE_MACHINE = "qemuarm|qemuarm64|qemux86|qemuppc|qemumips|qemumips64|qemux86-64|intel-corei7"

KBRANCH ?= "topic/gvt-xengt"
LINUX_VERSION ?= "4.18-rc8"
SRCREV ?= "d3251cf3a05739a24aa960edf1d28416b48665f6"

SRC_URI = " \
	   git://github.com/intel/gvt-linux.git;protocol=git;branch=${KBRANCH} \
           file://defconfig \
"

PV = "${LINUX_VERSION}+git${SRCPV}"

inherit kernel
require recipes-kernel/linux/linux-yocto.inc

LIC_FILES_CHKSUM = "file://LICENSES/preferred/GPL-2.0;md5=e6a75371ba4d16749254a51215d13f97"

do_configure_prepend() {
    cp ${WORKDIR}/defconfig ${B}/.config
}
