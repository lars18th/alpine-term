#!/usr/bin/env bash
##
##  Debugging script to run OS images supplied with Alpine Term.
##

set -e -u

# Use KVM to make things faster.
set -- "-enable-kvm"

# Set ram amount to 4GB.
set -- "${@}" "-m" "4096M"

# Do not create default devices.
set -- "${@}" "-nodefaults"

# Setup primary CD-ROM (with OS live image).
set -- "${@}" "-drive" "file=${PWD}/alpine-linux-cdrom.iso,index=0,media=cdrom,if=ide"

# Setup primary hard drive image (with the main OS installation).
set -- "${@}" "-device" "virtio-scsi-pci"
set -- "${@}" "-drive" "file=${PWD}/alpine-linux-hdd.qcow2,if=none,discard=unmap,cache=writeback,id=hd0"
set -- "${@}" "-device" "scsi-hd,drive=hd0"

# Allow to select boot device.
set -- "${@}" "-boot" "c,menu=on"

# Run in snapshot mode by default.
[ -z "${QEMU_NOSNAPSHOT:=}" ] && set -- "${@}" "-snapshot"

# Use virtio RNG. Provides a faster RNG for the guest OS.
set -- "${@}" "-object" "rng-random,filename=/dev/urandom,id=rng0"
set -- "${@}" "-device" "virtio-rng-pci,rng=rng0"

# Setup networking.
set -- "${@}" "-netdev" "user,id=vmnic0"
set -- "${@}" "-device" "virtio-net,netdev=vmnic0"

# Host storage access.
set -- "${@}" "-fsdev" "local,security_model=none,id=fsdev0,path=$HOME"
set -- "${@}" "-device" "virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=shared_storage"

# Disable graphical output.
set -- "${@}" "-vga" "none"
set -- "${@}" "-nographic"

# Monitor.
set -- "${@}" "-chardev" "tty,id=console0,mux=on,path=$(tty)"
set -- "${@}" "-serial" "chardev:console0"

# Disable parallel port.
set -- "${@}" "-parallel" "none"

qemu-system-x86_64 "$@" || true
stty sane
