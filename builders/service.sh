#!/bin/sh

ping 224.0.0.1 -c 1
mkdir ~macos-virt/.ssh || true
resize2fs /
cat /proc/cmdline  | sed 's/.*macos-virt-ssh-key=//g' | base64 -d > ~macos-virt/.ssh/authorized_keys

wait_for_commands() {
  while read -r line; do
    command=$(echo "$line" | cut -f1 -d,)

    case $command in
    shutdown)
      echo "Powering off"
      poweroff
      ;;
    time)
      new_time=$(echo "$line" | cut -f2 -d,)
      echo "Updating the time"
      date +%s -s "$new_time"
      ;;
    esac

  done </dev/hvc1

}

wait_for_commands