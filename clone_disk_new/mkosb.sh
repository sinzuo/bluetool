
echo "make system"

dmsetup remove_all
umount /mnt/boot
umount /mnt/var
umount /mnt/home
umount /mnt

#old vg name 
#using_vg_name=`ls /dev/mapper/VG*root|cut -d "/" -f 4|cut -d "-" -f1`
using_vg_name=`lsblk|grep "/home"|cut -d " " -f 3|cut -d "─" -f 2|cut -d "-" -f 1`
old_vg_name=`vgs|grep -Ev "$using_vg_name|PV"|awk -F " "  '{print $1}'`
echo "============ delete exist lvm =========="
echo y|lvremove /dev/mapper/$old_vg_name-var
echo y|lvremove /dev/mapper/$old_vg_name-home
echo y|lvremove /dev/mapper/$old_vg_name-root

echo y|vgremove $old_vg_name
echo y|pvremove /dev/sdb2



echo "============ Format sdb1 ==============="
mkfs.xfs -f /dev/sdb1
echo "============ Format sdb2 ==============="
mkfs.xfs -f /dev/sdb2



#vg name 
vg_name=VG`date +%s`
echo "============= create lvm ================"
echo y|pvcreate /dev/sdb2
vgcreate $vg_name /dev/sdb2

echo y|lvcreate -L 30G -n root $vg_name
echo y|lvcreate -L 20G -n var $vg_name
echo y|lvcreate -l 100%FREE -n home $vg_name



echo "============ Format lvm ==============="
mkfs.xfs -f  /dev/mapper/$vg_name-root
mkfs.xfs -f  /dev/mapper/$vg_name-var
mkfs.xfs -f  /dev/mapper/$vg_name-home



echo "============ mount / ==============="
mount /dev/mapper/$vg_name-root /mnt

cd /mnt
mkdir boot
mkdir var
mkdir mnt
mkdir proc
mkdir sys
mkdir dev
mkdir home

mount /dev/sdb1 /mnt/boot
mount /dev/mapper/$vg_name-var /mnt/var
mount /dev/mapper/$vg_name-home /mnt/home



echo "============ copy /[a-c]* ==============="
cp -r -p /[a-c]* /mnt

echo "============ copy /[e-i] ==============="
cp -r -p /[e-i]* /mnt

echo "============ copy /Data ==============="
cp -r -p /Data /mnt

echo "============ copy /lib ==============="
cp -r -p /lib /mnt

echo "============ copy /lib64 ==============="
cp -r -p /lib64 /mnt

echo "============ copy /media ==============="
cp -r -p /media /mnt

echo "============ copy /opt ==============="
cp -r -p /opt /mnt

echo "============ copy /root ==============="
cp -r -p /root /mnt

echo "============ copy /run ==============="
cp -r -p /run /mnt

echo "============ copy /sbin ==============="
cp -r -p /sbin /mnt

echo "============ copy /srv ==============="
cp -r -p /srv /mnt

echo "============ copy /tmp ==============="
cp -r -p /tmp /mnt

echo "============ copy /[uv]* ==============="
cp -r -p -v /[uv]* /mnt

echo "============ grub install ==============="
grub2-install --recheck /dev/sdb  --root-directory=/mnt

cp /home/clone_disk_new/fstab /mnt/etc/ -f
sed -i "s#volGroup#$vg_name#g" /mnt/etc/fstab

#boot 

boot_str=`lsblk |grep "/mnt/boot"|awk -F " " '{print $1}'`
second_boot="/dev/${boot_str: 2}"
uuid=`blkid $second_boot|awk -F " " '{print $2}'|awk -F "\""  '{print $2}'`
[ ! -z $uuid ] && sed -i "s#/dev/sda1#UUID=$uuid#g" /mnt/etc/fstab



cp /home/clone_disk_new/grub.cfg /mnt/boot/grub2 -f
sed -i "s#volGroup#$vg_name#g" /mnt/boot/grub2/grub.cfg

#modify ip config
#ifcfg_name=`ip addr|grep BROADCAST|grep -vE "virbr|vEth|vbox"|cut -d ":" -f 2|sort|head -1|cut -d " " -f 2`
#if [ ! -f "/mnt/etc/sysconfig/network-scripts/ifcfg-${ifcfg_name}" ]; then 
#	ifcfg_file_name=`find /etc/sysconfig/network-scripts/ -type f|xargs grep IPADDR|grep ifcfg|grep -v "lo"|cut -d ":" -f 1|head -1`
#	cp $ifcfg_file_name /mnt/etc/sysconfig/network-scripts/ifcfg-${ifcfg_name}
#fi 

#old_device_name=`cat /etc/sysconfig/network-scripts/ifcfg-eno1 |grep DEVICE|cut -d "=" -f2`
#new_device_name=$ifcfg_name
#sed -i "s#$old_device_name#$new_device_name#g" /mnt/etc/sysconfig/network-scripts/ifcfg-${ifcfg_name}
#echo "copy ifcfg-file-name successed"; 




chmod -R 777 /mnt/tmp

sleep 5

cd /
umount /mnt/boot
umount /mnt/var
umount /mnt/home
umount /mnt

#echo "============ finish ==============="
echo "拷盘成功"
