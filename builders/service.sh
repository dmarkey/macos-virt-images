#!/bin/sh -e

CONTROL_DIRECTORY=/var/lib/macos-virt/control
mount_control_dir() {
  mkdir -p $CONTROL_DIRECTORY
  mount -t virtiofs control $CONTROL_DIRECTORY
}


detect_ip() {
  IP_ADDRESS=""

  while [ "$IP_ADDRESS" = "" ] ; do
    IP_ADDRESS=$(ip addr | grep "inet " | grep 192.168 | cut -d " " -f6 | cut -d "/" -f1)
    sleep 1;
  done
  echo "$IP_ADDRESS" >> "$CONTROL_DIRECTORY"/ip
}


inject_ssh_key(){
  mkdir -p ~macos-virt/.ssh/
  cat "$CONTROL_DIRECTORY"/ssh_key >> ~macos-virt/.ssh/authorized_keys
}

provision_machine(){
  if [ -f "$CONTROL_DIRECTORY"/provision_script ] ; then
    sh -e "$CONTROL_DIRECTORY"/provision_script > "$CONTROL_DIRECTORY"/provision_script_output
    echo $? > "$CONTROL_DIRECTORY"/provision_script_return_code
  fi
}

run_startup_script(){
  if [ -f "$CONTROL_DIRECTORY"/startup_script ] ; then
    sh -e "$CONTROL_DIRECTORY"/startup_script > "$CONTROL_DIRECTORY"/startup_script_output
    echo $? > "$CONTROL_DIRECTORY"/startup_script_return_code
  fi
}

main_loop(){
  while true ; do

    if [ -f "$CONTROL_DIRECTORY"/time_sync ] ; then
      echo "Setting time"
      date +%s -s @$(stat -c "%Y" "$CONTROL_DIRECTORY"/time_sync)
      rm "$CONTROL_DIRECTORY"/time_sync
    fi
    if [ -f "$CONTROL_DIRECTORY"/poweroff ] ; then
      echo "Powering off"
      rm "$CONTROL_DIRECTORY"/poweroff
      poweroff
      exit
    fi
    echo "MemoryUsage:" $(free | grep Mem | awk '{print $3/$2 * 100.0}') > "$CONTROL_DIRECTORY"/heartbeat_tmp
    echo "CPUUsage:" $(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage }') >> "$CONTROL_DIRECTORY"/heartbeat_tmp
    echo "RootFsUsage:" $(df -h / | tail -1 | awk '{ print $5 }' | tr -d "%" ) >> "$CONTROL_DIRECTORY"/heartbeat_tmp
    mv "$CONTROL_DIRECTORY"/heartbeat_tmp "$CONTROL_DIRECTORY"/heartbeat
    sleep 1
  done
}

resize_root(){
  resize2fs /dev/vda
}
mount_usr_directory(){
  if [ -f "$CONTROL_DIRECTORY"/mnt_usr_directory ] ; then
    usr_directory=$(cat "$CONTROL_DIRECTORY"/mnt_usr_directory)
    mkdir -p "$usr_directory"
    mount -t virtiofs home "$usr_directory"
  fi
}

resize_root
mount_control_dir
detect_ip
mount_usr_directory

if [ ! -f "$CONTROL_DIRECTORY"/initialized ] ; then
  inject_ssh_key
  provision_machine
  touch "$CONTROL_DIRECTORY"/initialized
fi
run_startup_script
main_loop








