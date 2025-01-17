#!/bin/bash
#Update Centos to latest packages
sudo yum -y update
#Installing Docker dependencies
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
#Add docker repository
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#Installing docker
sudo yum -y install docker-ce-18.09.9-3.el7
#Adding current user to group
sudo usermod -aG docker $(whoami)
#Setting Docker to boot at start time
sudo systemctl enable docker.service
#Starting docker service
sudo systemctl start docker.service
# Add kubernetes repository
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet
# RemoveSwap
swapoff -a
# Change network proc to 1 (Might not be required)
cat /usr/lib/sysctl.d/00-system.conf
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --reload

modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
kubeadm init

# Create the kubernetes config in home directory
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

#Create pod network so containers can talk to each other
export kubever=$(kubectl version | base64 | tr -d '\n')
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"