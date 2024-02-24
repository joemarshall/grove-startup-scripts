#! /bin/bash
#
# Script to give a pi a new identity, for use after cloning an image

get_variables () {
  ROOT_PART_DEV=$(findmnt / -no source)
  ROOT_DEV_NAME=$(lsblk -no pkname  "$ROOT_PART_DEV")
  ROOT_DEV="/dev/${ROOT_DEV_NAME}"

  BOOT_PART_DEV=$(findmnt "$FWLOC" -no source)
  BOOT_PART_NAME=$(lsblk -no kname "$BOOT_PART_DEV")
  BOOT_DEV_NAME=$(lsblk -no pkname  "$BOOT_PART_DEV")
  BOOT_PART_NUM=$(cat "/sys/block/${BOOT_DEV_NAME}/${BOOT_PART_NAME}/partition")

  OLD_DISKID=$(fdisk -l "$ROOT_DEV" | sed -n 's/Disk identifier: 0x\([^ ]*\)/\1/p')
}

fix_partuuid() {
  if [ "$BOOT_PART_NUM" != "1" ]; then
    return 0
  fi
  DISKID="$(dd if=/dev/hwrng bs=4 count=1 status=none | od -An -tx4 | cut -c2-9)"
  fdisk "$ROOT_DEV" > /dev/null <<EOF
x
i
0x$DISKID
r
w
EOF
  if [ "$?" -eq 0 ]; then
    sed -i "s/${OLD_DISKID}/${DISKID}/g" /etc/fstab
    sed -i "s/${OLD_DISKID}/${DISKID}/" "$FWLOC/cmdline.txt"
    sync
  fi

}

regenerate_ssh_host_keys () {
  /usr/lib/raspberrypi-sys-mods/regenerate_ssh_host_keys
  RET="$?"
  return "$RET"
}

get_variables

fix_partuuid

regenerate_ssh_host_keys