SRCREV = "${AUTOREV}"

XEN_REL = "4.10"
XEN_BRANCH = "xengt-stable-4.10"
SRCPV = "${SRCREV}"
PV = "${XEN_REL}+git"

S = "${WORKDIR}/git"

SRC_URI = " \
    git://github.com/intel/igvtg-xen;protocol=http;branch=${XEN_BRANCH} \
    "

DEFAULT_PREFERENCE = "-1"
