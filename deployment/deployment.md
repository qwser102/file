tar -xvf installer-core-v4.2.0-x86.tar

vi /etc/default/grub
在GRUB_CMDLINE_LINUX= 这一行，在 crashkernel 后增加 cgroup.memory=nokmem 参数并执行grub2-mkconfig -o /boot/grub2/grub.cfg命令并重启后，能在 /proc/cmdline 中找到增加的，即代表更改成功
