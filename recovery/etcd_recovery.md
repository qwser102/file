### 1. Backup

```shell
# etcd data backup
mkdir -p /root/backup_$(date +%Y%m%d%H)/old-etcd/
export ETCDCTL_API=3
cp $(find /var/lib/containerd/ -name etcdctl | tail -1)  /root/etcdctl 

ETCDCTL_API=3 etcdctl --endpoints 127.0.0.1:2379 --cert="/etc/kubernetes/pki/etcd/server.crt" --key="/etc/kubernetes/pki/etcd/server.key" --cacert="/etc/kubernetes/pki/etcd/ca.crt" snapshot save /root/backup_$(date +%Y%m%d%H)/snap.db
```

### 2. Recover

```shell
# Do the follow 4 steps in three master nodes
# 1. login to all three master nodes, And backup ETCD yaml.

mkdir -p /root/backup_$(date +%Y%m%d%H)/old-etcd/
systemctl stop kubelet

cp $(find /var/lib/containerd/ -name etcdctl | tail -1)  /root/etcdctl 

# 2. stop etcd pod
crictl  ps -a | grep etcd | awk '{print $1}' | xargs crictl rm -f
 
# 3. clear the etcd data dir and backup the kubernetes config 
mv /var/lib/etcd/* /root/backup_$(date +%Y%m%d%H)/old-etcd/
cp -r /etc/kubernetes/ /root/backup_$(date +%Y%m%d%H)/old-etcd/

# 4. modify the etcd.yaml
sed -i /initial-cluster-state=/d /etc/kubernetes/manifests/etcd.yaml
sed -i '/initial-cluster=/a\    - --initial-cluster-state=existing' /etc/kubernetes/manifests/etcd.yaml 
#【Do make sure the etc/kubernetes/manifests/etcd.yaml indent， - --initial-cluster-state=existing 】


# Login to the master1
# 5. Copy the latest backed-up ETCD snapshot to the /tmp directory on the first master node and rename it as snapshot.db


# 6. login to the master1 and recover the ETCD.
# etcd_recover.sh
#!/usr/bin/env bash

# IP
export ETCD_1=1.1.1.1
export ETCD_2=2.2.2.2
export ETCD_3=3.3.3.3

# nodes hostname
export ETCD_1_HOSTNAME=etcd-1
export ETCD_2_HOSTNAME=etcd-2
export ETCD_3_HOSTNAME=etcd-3

export ETCDCTL_API=3

for n in 1 2 3; do
  ip_var=ETCD_${n}
  host_var=ETCD_${n}_HOSTNAME

  ip=${!ip_var}          # equal to：n=1 -> ip=$ETCD_1
  host=${!host_var}      # equal to：n=1 -> host=$ETCD_1_HOSTNAME
  rm -rf /tmp/etcd
  /root/etcdctl snapshot restore /tmp/snapshot.db \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --skip-hash-check=true \
    --data-dir=/tmp/etcd \
    --name "${host}" \
    --initial-cluster \
      ${ETCD_1_HOSTNAME}=https://${ETCD_1}:2380,\
${ETCD_2_HOSTNAME}=https://${ETCD_2}:2380,\
${ETCD_3_HOSTNAME}=https://${ETCD_3}:2380 \
    --initial-advertise-peer-urls https://"${ip}":2380 && \
    mv /tmp/etcd /root/etcd_"${host}"
done

# bash etcd_recover.sh

**promption**：
 
# 7. This will generate three etcd_$host directories in /root  
# Copy the member directory from these three directories to the /var/lib/etcd/ directory corresponding to the IP address.

# 8. Login to 3 master nodes：
 
crictl ps -a | grep -E "kube-api|kube-sche|kube-contro" | awk '{print $1}' | xargs crictl rm -f 
systemctl restart kubelet

# 9. Check kubectl command can be used，and etcd pods are running.
kubectl get no
kubectl get po -A |gre etcd

# 10. Restart all node's kubelet
systemctl restart kubelet

# 11. Restart one pod to make sure that the cluster is running ok.
```

