#!/bin/bash

user="$(w -h -s | awk '/:[0-9]/ {print $1}' | head -1)"
userhome=$(getent passwd $user | cut -d: -f6)

ACPI_Event() {
  case $1 in
    power)
      case $2 in
        button) _Poweroff ;;
      esac
      ;;
     volume)
       case $2 in
         output)
           case $3 in
             up)   su $user -l -c "DISPLAY=:0.0 ${userhome}/bin/volume up"   ;;
           down)   su $user -l -c "DISPLAY=:0.0 ${userhome}/bin/volume down" ;;
             mute) su $user -l -c "DISPLAY=:0.0 ${userhome}/bin/volume mute" ;;
           esac
           ;;
       esac
       ;;
  esac
  logger "ACPI Event: $@"
}

case "$@" in
  button/power*)      ACPI_Event power button       ;;
  button/volumeup*)   ACPI_Event volume output up   ;;
  button/volumedown*) ACPI_Event volume output down ;;
  button/mute*)       ACPI_Event volume output mute ;;
  *)                  ACPI_Event "$@"               ;;
esac

_Poweroff() {
  /sbin/shutdown -h -P now "Power button pressed"
}
