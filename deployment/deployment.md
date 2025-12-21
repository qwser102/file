tar -xvf installer-core-v4.2.0-x86.tar

scp installer/res/init.sh ${global_node_ip}:/tmp
bash /tmp/init.sh

Add `cgroup.memory=nokmem` before the `crashkernel` in line start with `GRUB_CMDLINE_LINUX=`, and then run the follow command:
$ vi /etc/default/grub
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="crashkernel=auto cgroup.memory=nokmem resume=UUID=f5b69bea-3587-4a24-9a5e-85940d428413 rhgb quiet"
GRUB_DISABLE_RECOVERY="true"
GRUB_ENABLE_BLSCFG=true

$ grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
done

reboot

cat /proc/cmdline

login to the global master1
cd install/
bash setup.sh


```
violet push extensions/ --platform-address https://192.168.176.48 --platform-username admin --platform-password 1qaz@WSX
```

