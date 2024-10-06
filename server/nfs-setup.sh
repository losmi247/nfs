#!/bin/bash

# exit if command fails
set -e

# all directories to be exported
mounts="${@}"

echo "#NFS Exports" > /etc/exports

# create and export the directories
for mnt in "${mounts[@]}"; do
  src=$(echo $mnt | awk -F ':' '{ print $1 }')
  mkdir -p $src
  echo "$src *(rw,sync,no_subtree_check,fsid=0,no_root_squash)" >> /etc/exports
done

# just for testing
touch /nfs_share/a.txt

# run all the scripts - init,stop
exec runsvdir /etc/sv