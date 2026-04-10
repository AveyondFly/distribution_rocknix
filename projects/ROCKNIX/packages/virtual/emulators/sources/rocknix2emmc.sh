#!/bin/bash

IMAGE="/roms/dd.img"
if [ ! -f $IMAGE ]; then
	echo "Image not found!"
	exit 1
fi

mpv --really-quiet --image-display-duration=6000 /usr/share/cbepx/bg.png &

regenerate_img() {
	# 创建循环设备
	LOOP_DEV=$(losetup -fP --show "$1")
	echo "分区设备已映射到: $LOOP_DEV"

	# 处理所有分区
	for PART in "${LOOP_DEV}p"*; do
	  FSTYPE=$(blkid -o value -s TYPE "$PART")
	  echo "处理分区 $PART [类型: $FSTYPE]"
	  
	  case "$FSTYPE" in
		ext4)
		  echo "修改EXT4 UUID..."
		  tune2fs -U random "$PART"
		  ;;
		vfat)
		  echo "修改FAT32序列号..."
		  NEW_SERIAL=$(tr -dc 'A-F0-9' < /dev/urandom | head -c8)
		  fatlabel -i "$NEW_SERIAL" "$PART"
		  ;;
		*)
		  echo "未知文件系统，跳过"
		  ;;
	  esac
	done

	# 清理
	losetup -d "$LOOP_DEV"
	echo "操作完成！新标识符:"
	blkid "$1"
}

update_extlinux() {
	# 定义镜像路径和挂载点
	IMAGE=$1
	MOUNT_DIR="/tmp/image_p1"
	HOST_CONF="/flash/extlinux/extlinux.conf"
	HOST_CONF_INI="/flash/boot.ini"
	IMAGE_CONF="$MOUNT_DIR/extlinux/extlinux.conf_bak"
	IMAGE_DST_CONF="$MOUNT_DIR/extlinux/extlinux.conf"

	# 检查镜像文件是否存在
	if [ ! -f "$IMAGE" ]; then
		echo "错误：镜像文件 $IMAGE 不存在！"
		exit 1
	fi

	# 创建挂载点
	mkdir -p "$MOUNT_DIR"

	# 设置循环设备并挂载第一个分区
	LOOP_DEV=$(losetup -fP --show "$IMAGE")
	if [ $? -ne 0 ]; then
		echo "错误：无法创建循环设备！"
		exit 1
	fi

	echo "镜像已映射到: $LOOP_DEV"

	# 挂载第一个分区 (p1)
	mount "${LOOP_DEV}p1" "$MOUNT_DIR"
	if [ $? -ne 0 ]; then
		echo "错误：无法挂载第一个分区！"
		losetup -d "$LOOP_DEV"
		exit 1
	fi

	IMAGE_CONF="$IMAGE_DST_CONF"

	if [ -f "$HOST_CONF" ]; then
		# 从宿主配置中提取 FDT 值
		HOST_FDT_VALUE=$(grep -E '^\s*FDT\s+/' "$HOST_CONF" | head -1 | awk '{print $2}')
	elif [ -f "$HOST_CONF_INI" ]; then
		HOST_FDT_VALUE_TMP=$(sed -n 's/.*load mmc 1:1 \${dtb_loadaddr} //p' "$HOST_CONF_INI")
		HOST_FDT_VALUE=$(printf "/%s" "$HOST_FDT_VALUE_TMP")
	fi
	if [ -z "$HOST_FDT_VALUE" ]; then
		echo "错误：无法从宿主配置中提取 FDT 值！"
		echo "检查 $HOST_CONF 文件内容："
		cat "$HOST_CONF"
		umount "$MOUNT_DIR"
		losetup -d "$LOOP_DEV"
		exit 1
	fi

	cp "$HOST_CONF" "$IMAGE_DST_CONF"

	echo "从宿主配置中提取的 FDT 值: $HOST_FDT_VALUE"

	# 清理
	umount "$MOUNT_DIR"
	losetup -d "$LOOP_DEV"
	rmdir "$MOUNT_DIR"

	echo "操作完成！镜像中的 FDT 路径已更新为宿主配置的值"
}

umount_emmc_partition() {
	# 获取所有已挂载的mmcblk0分区
	mounted_partitions=$(grep -oP '/dev/mmcblk0p?\d+' /proc/mounts | sort -u)

	if [ -z "$mounted_partitions" ]; then
		echo "没有找到已挂载的 /dev/mmcblk0 分区"
		return 0
	fi

	echo "找到以下已挂载分区："
	echo "$mounted_partitions"

	# 尝试卸载所有分区（使用lazy卸载作为后备）
	for partition in $mounted_partitions; do
		echo -n "正在卸载 $partition ... "
		
		# 先尝试正常卸载
		if umount "$partition" 2>/dev/null; then
			echo "[成功]"
			continue
		fi
		
		# 如果正常卸载失败，尝试延迟卸载
		if umount -l "$partition" 2>/dev/null; then
			echo "[延迟卸载]"
		else
			echo "[失败]"
			echo "错误：无法卸载 $partition"
			echo "可能有进程正在使用该分区："
			lsof "$partition" 2>/dev/null || echo "无法获取使用信息"
			exit 1
		fi
	done
}

umount_emmc_partition

regenerate_img $IMAGE
update_extlinux $IMAGE

echo "开始写入emmc，请耐心等待..."
dd if=$IMAGE of=/dev/mmcblk0 bs=1M
echo "写入完成!"
sleep 2
kill -9 `pidof mpv`
