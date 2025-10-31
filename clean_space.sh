#!/bin/bash
set -e
[ "$EUID" -ne 0 ] && echo "請以 root 身份執行" && exit 1
for c in lsblk growpart pvresize lvextend resize2fs df; do
  command -v $c >/dev/null 2>&1 || { apt-get update -y >/dev/null 2>&1; apt-get install -y cloud-guest-utils lvm2 >/dev/null 2>&1 || yum install -y cloud-utils-growpart lvm2 >/dev/null 2>&1; break; }
done
ROOT_LV=$(df / | tail -1 | awk '{print $1}')
FS_TYPE=$(df -T / | tail -1 | awk '{print $2}')
if [[ $ROOT_LV == /dev/mapper/* ]]; then
  VG_NAME=$(lvs --noheadings -o vg_name "$ROOT_LV" | xargs)
  PV_NAME=$(pvs --noheadings -o pv_name | head -1 | xargs)
  DISK=$(echo "$PV_NAME" | sed -E 's/[0-9]+$//')
  PART_NUM=$(echo "$PV_NAME" | grep -o '[0-9]*$')
  growpart "$DISK" "$PART_NUM" || true
  pvresize "$PV_NAME" || true
  lvextend -l +100%FREE "$ROOT_LV" || true
  [[ "$FS_TYPE" == "ext4" ]] && resize2fs "$ROOT_LV" || [[ "$FS_TYPE" == "xfs" ]] && xfs_growfs /
else
  DEV=$(lsblk -no pkname $(df / | tail -1 | awk '{print $1}') | head -1)
  PART_NUM=$(lsblk -no name | grep "^$DEV" | tail -1 | grep -o '[0-9]*$')
  growpart "/dev/$DEV" "$PART_NUM" || true
  [[ "$FS_TYPE" == "ext4" ]] && resize2fs "$(df / | tail -1 | awk '{print $1}')" || [[ "$FS_TYPE" == "xfs" ]] && xfs_growfs /
fi
df -h /
lsblk
