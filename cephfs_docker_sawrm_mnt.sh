#!/bin/bash

#
#
#   CephFS Docker Swarm Mount Service Setup Script v1.0
#	
#   Author:
#	  Armando Galleogs III <personal@armandogallegos.com>
# 
#   Thank you family for putting up with my late night
#   coding sessions!
# 
#

if [ `id -u` -ne 0 ]
  then echo "root access required, try sudo ./${0##*/}"
  exit
fi

# GET REQUIRED PACKAGES
apt-get update
apt-get install -y ceph-common

# PULLS NODE LIST FROM 'CEPH MON STAT'
cephfs_mons=$(ceph mon stat | grep -oP '\b[a-zA-Z0-9]+(?==)' | tr '\n' ',' | sed 's/,$//')

mnt_service='var-lib-docker-volumes.mount'
mnt_what_path='/docker/volumes'
mnt_where_path='/var/lib/docker/volumes'
cephfs_secret=`ceph-authtool -p /etc/ceph/ceph.client.admin.keyring`

mkdir -p $mnt_where_path

echo -e "[Unit]
Description=Mount CephFS at $mnt_where_path
After=network-online.target
Wants=network-online.target

[Mount]
What=$cephfs_mons:$mnt_what_path
Where=$mnt_where_path
Type=ceph
Options=name=admin,secret=$cephfs_secret,_netdev
TimeoutSec=15

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/$mnt_service
systemctl daemon-reload
systemctl enable $mnt_service
systemctl start $mnt_service