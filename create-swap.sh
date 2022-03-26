#!/usr/bin/env bash
# Source: https://docs.splynx.com/getting_started_guide/create_swap_file

if (( $# < 1 )); then
  size=1
else
  size=$1
fi
if [[ ! -f /swapfile ]]; then
    echo "Building swapfile $size Gb ..."
    dd if=/dev/zero of=/swapfile bs=100M count=$(( size*10 ))
    mkswap /swapfile
    chmod 0600 /swapfile
    swapon /swapfile

    # Mount on boot
    if [[ -z "$(cat /etc/fstab | grep swapfile)" ]]; then
        echo "Modifying /etc/fstab ..."
        echo "/swapfile none swap sw 0 0" | tee -a /etc/fstab > /dev/null 2>&1
    fi
else
  echo "/swapfile already present"
fi
