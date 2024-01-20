#!/bin/bash

#################################################################
#																                                #
#   CephFS Docker Swarm Mount Service Setup Script v1.0         #
#																                                #
#   Author: 													                          #
#	  Armando Galleogs III <personal@armandogallegos.com> 		    #
#                                                               #
#   Thank you family for putting up with my late night          #
#   coding sessions! 															              #
#                                                               #
#################################################################

if [ `id -u` -ne 0 ]
  then echo "root access required, try sudo ./${0##*/}"
  exit
fi

# GET REQUIRED PACKAGES
apt-get update
apt-get install -y ceph-common

# PULLS NODE LIST FROM 'CEPH MON STAT'
cephfs_mons=$(ceph mon stat | grep -oP '\b[a-zA-Z0-9]+(?==)' | tr '\n' ',' | sed 's/,$//')

cephfs_mnt_service='/etc/systemd/system/docker-swarm-mnt-cephfs.mount'
cephfs_mnt_src_path='/docker/volumes'
cephfs_mnt_point='/var/lib/docker/volumes'
cephfs_secret=`ceph-authtool -p /etc/ceph/ceph.client.admin.keyring`

mkdir -p $cephfs_mnt_point

echo -e "[Unit]
Description=Mount CephFS at $cephfs_mnt_point
After=network-online.target
Wants=network-online.target

[Mount]
What=$cephfs_mons:$cephfs_mnt_src_path
Where=$cephfs_mnt_point
Type=ceph
Options=name=admin,secret=$cephfs_secret,_netdev
TimeoutSec=15

[Install]
WantedBy=multi-user.target" > $cephfs_mnt_service
systemctl daemon-reload
systemctl enable $cephfs_mnt_service
systemctl status $cephfs_mnt_service