#!/bin/bash
#
# Install Kubernetes Master (First Time)
#
# Hostname cannot be changed after kubeadm
#echo "Changing Hostname ..."
#sudo hostnamectl set-hostname k8s-master
# ref. https://qiita.com/nnagashima/items/d7deb00d086b6e276eea
echo "Cleanup kubeadm information ..."
sudo kubeadm reset -f
echo "Initializing with kubeadm init ..."
#sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=Mem
# --control-plan-endpoint is for high-availability masters cluster
sudo kubeadm init --control-plane-endpoint "k8s-master:16443" --upload-certs --pod-network-cidr=10.244.0.0/16

# You will see Docker version error with 20.0.1. Need to use 19.03
# ref. https://qiita.com/soumi/items/7736ac3aabbbe4fb474a
# If succeeded, you will see messages:
# "Your Kubernetes control-plane has initialized successfully!"
if [ $? -gt 0 ]; then
    echo "Kubeadm init failed. Abort."
    exit 1
fi

# Copy Kubernetes config files as instructed
echo "Copying config to $HOME/.kube ..."
mkdir -p $HOME/.kube
sudo cp -f -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
aws s3 cp $HOME/.kube/config s3://nirecom-home/.kube/

# Edit iptables for flannel
# not necessary for Ubuntu 20.04 LTS
#sudo sysctl net.bridge.bridge-nf-call-iptables=1