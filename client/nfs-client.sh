#!/bin/bash

# the ip address of the server from where we want to mount
export NFS_PORT_2049_TCP_ADDR=192.168.100.1

set -e

# enable NFSv2 on 22.04
# echo -e "[nfsd]\nudp=n\ntcp=y\nvers2=y\nvers3=y\nvers4=y" | tee /etc/nfs.conf.d/local.conf

# enable NFSv2 and disable NFSv3 and NFSv4
# crudini --set /etc/nfs.conf nfsd vers2 y
# crudini --set /etc/nfs.conf nfsd vers3 n
# crudini --set /etc/nfs.conf nfsd vers4 n
# enable tcp and udp
# crudini --set /etc/nfs.conf nfsd tcp y
# crudini --set /etc/nfs.conf nfsd udp y

# mount NFS server directories onto client host
mounts="${@}"
targets=()

rpcbind

for mnt in "${mounts[@]}"; do
  # directory on server to be mounted on client
  server_source=$(echo $mnt | awk -F':' '{ print $1 }')
  # target on client where we want to mount the server directory
  client_target=$(echo $mnt | awk -F':' '{ print $2 }')

  targets+=("$client_target")


  mkdir -p $client_target
  # mount the server directory on client target (file system type is nfs)
  # ('mount -t type device dir' mounts the device of type type at the directory dir)
  mount --types nfs --options proto=tcp,port=2049,vers=2 ${NFS_PORT_2049_TCP_ADDR}:${server_source} ${client_target}
done

echo "Monitoring changes in mounted directories..."
inotifywait -m "${targets[@]}"