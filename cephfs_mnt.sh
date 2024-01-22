#!/bin/bash

#
#
#   CephFS Mount Script v1.0
#	
#   Author:
#	  Armando Galleogs III <personal@armandogallegos.com>
# 
#   Thanks to my family who puts up with my late-night 
#   code sessions!
# 
#

if [ `id -u` -ne 0 ]
  then echo "root access required, try sudo ./${0##*/}"
  exit
fi

apt-get update
apt-get install -y ceph-common

cephfs_mons=$(ceph mon stat | grep -oP '\b[a-zA-Z0-9]+(?==)' | tr '\n' ',' | sed 's/,$//')

mnt_service='mnt-cephfs.mount'
mnt_what='/'
mnt_where='/mnt/cephfs'
cephfs_secret=`ceph-authtool -p /etc/ceph/ceph.client.admin.keyring`

mkdir -p $mnt_where

echo -e "[Unit]
Description=Mount CephFS at $mnt_where
After=network-online.target
Wants=network-online.target

[Mount]
What=$cephfs_mons:$mnt_what
Where=$mnt_where
Type=ceph
Options=name=admin,secret=$cephfs_secret,_netdev
TimeoutSec=15

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/$mnt_service
systemctl daemon-reload
systemctl enable $mnt_service
systemctl start $mnt_service