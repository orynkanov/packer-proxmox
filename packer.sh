#!/bin/bash

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

CONFIG_DIR=$1
export VERSION=$2

#start check
if [[ ! $# -eq 2 ]]; then
    echo "Usage - packer.sh CONFIG_DIR VERSION_NUMBER"
    exit 1
fi

if [[ ! -f $SCRIPTDIR/$CONFIG_DIR/packer.json ]]; then
    echo "File $SCRIPTDIR/$CONFIG_DIR/packer.json not found"
    exit 1
fi
if [[ ! -f $SCRIPTDIR/$CONFIG_DIR/ks.cfg.tmpl ]]; then
    echo "File $SCRIPTDIR/$CONFIG_DIR/ks.cfg.tmpl not found"
    exit 1
fi

re='^[0-9]+$'
if ! [[ $VERSION =~ $re ]] ; then
   echo "$VERSION not number"
   exit 1
fi
#finish check

export PROXMOX_URL='https://hyper01.yozhu.home:8006/api2/json'
export PROXMOX_USERNAME='root@pam'
export SSH_PASSWORD='rootpw'

if [[ -z $PROXMOX_PASSWORD ]]; then
    read -r -s -p "Enter password for proxmox login $PROXMOX_USERNAME: " PASS
    export PROXMOX_PASSWORD=$PASS
fi
echo

rm -f "$SCRIPTDIR"/"$CONFIG_DIR"/ks.cfg
cp "$SCRIPTDIR"/"$CONFIG_DIR"/ks.cfg.tmpl "$SCRIPTDIR"/"$CONFIG_DIR"/ks.cfg
sed -i "s/%ROOTPW%/$SSH_PASSWORD/" "$SCRIPTDIR"/"$CONFIG_DIR"/ks.cfg

if ! packer validate "$SCRIPTDIR"/"$CONFIG_DIR"/packer.json; then
    echo "Validate config failed!"
    exit 1
else
    packer build "$SCRIPTDIR"/"$CONFIG_DIR"/packer.json
fi
