#!/bin/bash
# 自動擴展根分割區以使用全部硬碟空間
# 適用 Ubuntu / Debian 使用 LVM 的環境

set -e

echo "開始執行磁碟最大化程序..."

# 1. 找出根邏輯卷
ROOT_LV=$(df / | tail -1 | awk '{print $1}')

if [[ $ROOT_LV != /dev/mapper/* ]]; then
    echo "錯誤：系統未使用 LVM，請手動使用 growpart 或 resize2fs。"
    exit 1
fi

echo "偵測到根邏輯卷：$ROOT_LV"

# 2. 找出對應的 Volume Group
VG_NAME=$(sudo lvdisplay "$ROOT_LV" | awk '/VG Name/{print $3}')
PV_NAME=$(sudo pvs --noheadings -o pv_name | head -1)

echo "Volume Group：$VG_NAME"
echo "Physical Volume：$PV_NAME"

# 3. 嘗試自動擴展 PV（需有未分配磁碟空間）
echo "擴展 PV 以使用整顆磁碟..."
sudo pvresize "$PV_NAME"

# 4. 擴展 LV
echo "擴展 LV..."
sudo lvextend -l +100%FREE "$ROOT_LV"

# 5. 根據檔案系統類型自動擴展
FS_TYPE=$(df -T / | tail -1 | awk '{print $2}')
echo "檔案系統類型：$FS_TYPE"

if [[ "$FS_TYPE" == "ext4" ]]; then
    sudo resize2fs "$ROOT_LV"
elif [[ "$FS_TYPE" == "xfs" ]]; then
    sudo xfs_growfs /
else
    echo "警告：未支援的檔案系統類型 $FS_TYPE，請手動處理。"
fi

echo
echo "磁碟擴展完成！目前使用情況如下："
df -h /
