#!/bin/sh

PATH=/sbin:/bin:/usr/sbin:/usr/bin
ROOT_MOUNT=/mnt/root
IP=$(which ip)
LN=$(which ln)
MKDIR=$(which mkdir)
MKNOD=$(which mknod)
MKTEMP=$(which mktemp)
MODPROBE=$(which modprobe)
MOUNT=$(which mount)
SLEEP=$(which sleep)
UDEVADM=$(which udevadm)
[ -z "$CONSOLE" ] && CONSOLE="/dev/console"

fatal () {
echo $1 >$CONSOLE
echo >$CONSOLE
PS1='gvtg# ' exec sh
}

# sanity
[ ! -x $IP ]       && fatal "No ip command."
[ ! -x $LN ]       && fatal "No ln command."
[ ! -x $MKDIR ]    && fatal "No mkdir command."
[ ! -x $MKNOD ]    && fatal "No mknod command."
[ ! -x $MKTEMP ]   && fatal "No mktemp command."
[ ! -x $MODPROBE ] && fatal "No modprobe command."
[ ! -x $MOUNT ]    && fatal "No mount command."
[ ! -x $SLEEP ]    && fatal "No sleep command."
[ ! -x $UDEVADM ]    && fatal "No udevadm command."

makedir () {
for DIR in $@; do
if [ ! -e $DIR ]; then
    $MKDIR -p $DIR
fi
done
}

early_setup () {
mknod -m 600 console c 5 1
mknod -m 666 null c 1 3
mknod -m 666 zero c 1 5

makedir /proc /sys
$MOUNT -t proc proc /proc
$MOUNT -t sysfs sysfs /sys

makedir /tmp /run
$LN -s /run /var/run

$MODPROBE nvme
$MODPROBE i915
$MODPROBE xengt
$MODPROBE vfio-iommu-type1
$MODPROBE vfio-mdev

if grep -q devtmpfs /proc/filesystems; then
$MOUNT -t devtmpfs devtmpfs $rootmnt/dev
fi

$UDEVADM settle
}

read_args() {
[ -z "$CMDLINE" ] && CMDLINE=`cat /proc/cmdline`
for arg in $CMDLINE; do
optarg=`expr "x$arg" : 'x[^=]*=\(.*\)'`
case $arg in
    ro)
	ROOT_MODE=$arg ;;
    rw)
	ROOT_MODE=$arg ;;
    rootimg=*)
	ROOT_IMAGE=$optarg ;;
    console=*)
	if [ -z "${console_params}" ]; then
	    console_params=$arg
	else
	    console_params="$console_params $arg"
	fi
	;;
esac
done
}

find_rootimg() {
    local rootimg=$1
    [ -z $rootimg ] && fatal "No image for root file system provided."

    echo "Scanning for physical volumes"
    pvscan
    $UDEVADM settle

    vgdisplay dom0
    rc="$?"
    while [ "$rc" != "0" ]
    do
        pvscan
        vgscan
        sleep 1
        vgdisplay dom0
        rc="$?"
    done

    lvscan
    lvchange -ay dom0
    $MKDIR /storage
    $MOUNT /dev/dom0/storage /storage
    ROOT_IMAGE_PATH=/storage/$1
    [ -z $ROOT_IMAGE_PATH ] && fatal "could not find root image: $rootimg"
}

mount_rootimg() {
    local root_img=$1
    local root_mnt=$2
    local loop_dev=/dev/loop0

    [ -z $root_img ] && fatal "no image file passed to mount_rootimg"
    [ -z $root_mnt ] && fatal "no mount point passed to mount_rootimg "

    makedir $root_mnt
    [ ! -b $loop_dev ] && $MKNOD $loop_dev b 7 0
    if ! $MOUNT -o ${ROOT_MODE},loop,noatime,nodiratime $root_img $root_mnt ; then
        fatal "Failed to mount rootfs image."
    fi
}

boot_root() {
    local rootmnt=$1

    [ -z $rootmnt ] && fatal "no root mount given to boot_root"
    $MKDIR -p $rootmnt/storage
    $MOUNT --bind /storage $rootmnt/storage

    cd $rootmnt
    exec switch_root -c $CONSOLE $rootmnt /sbin/init
}

early_setup
read_args
find_rootimg $ROOT_IMAGE
mount_rootimg $ROOT_IMAGE_PATH $ROOT_MOUNT
boot_root $ROOT_MOUNT

fatal "Failed to switch to root image: $ROOT_IMAGE ... unable to continue."
