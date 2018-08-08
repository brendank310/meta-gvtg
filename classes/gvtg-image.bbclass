inherit image

IMAGE_LINGUAS = "en-us"

IMAGE_INSTALL = "\
    base-files \
    base-passwd \
    bind-utils \
    coreutils \
    lsb \
    gawk \
    grep \
    nano \
    netbase \
    rng-tools \
    sed \
    shadow \
    systemd \
    systemd-compat-units \
    vim-tiny \
    ${MACHINE_ESSENTIAL_EXTRA_RDEPENDS} \
"

IMAGE_FEATURES = " \
    read-only-rootfs \
    empty-root-password \
    allow-empty-password \
"

IMAGE_FEATURES += " \
    debug-tweaks \
    package-management \
"

IMAGE_INSTALL += " \
    binutils \
    curl \
    file \
    findutils \
    gdb \
    gzip \
    ldd \
    less \
    lsof \
    openssh \
    opkg \
    opkg-utils \
    strace \
    tcpdump \
    pciutils \
    procps \
    psmisc \
    rsync \
    tar \
    usbutils \
    wget \
    which \
    zlib \
    xz \
"

sshd_permit_empty_password() {
    sed -i 's|#PermitEmptyPasswords no|PermitEmptyPasswords yes|g' ${IMAGE_ROOTFS}${sysconfdir}/ssh/sshd_config
}

ROOTFS_POSTPROCESS_COMMAND_append = " \
    sshd_permit_empty_password; \
"

IMAGE_ROOTFS_SIZE ?= "8192"
IMAGE_ROOTFS_EXTRA_SPACE_append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "" ,d)}"
