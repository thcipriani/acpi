#!/bin/bash

user="$(w -h -s | awk '/:[0-9]/ {print $1; exit;}')"
userhome=$(getent passwd $user | cut -d: -f6)

logger "ACPI Event: $@"

ACPI_Event() {
  case $1 in
    power)
      case $2 in
        button) _Poweroff ;;
        ac) su $user -l -c "DISPLAY=:0.0 ${userhome}/bin/power" ;;
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

    tablet) su $user -l -c "DISPLAY=:0.0 ${userhome}/bin/display tabletmode" ;;

    brightness)
        case $2 in
            keyboard)
                case $3 in
                    up) DISPLAY=:0.0 $userhome/bin/keyboard-bl up ;;
                    down) DISPLAY=:0.0 $userhome/bin/keyboard-bl down ;;
                    revolve) DISPLAY=:0.0 $userhome/bin/keyboard-bl revolve ;;
                esac
            ;;
        esac
    ;;
   esac
}


case "$@" in
  button/power*)                   ACPI_Event power button ;;
  button/volumeup*)                ACPI_Event volume output up ;;
  button/volumedown*)              ACPI_Event volume output down ;;
  button/mute*)                    ACPI_Event volume output mute ;;
  video/tabletmode*TBLT*)          ACPI_Event tablet ;;
  ibm/hotkey\ LEN0068:00*6030)     ACPI_Event power ac ;;
  PNP0C14\:00\ 000000ff\ 00000000) ACPI_Event brightness keyboard revolve;;
#  ibm/hotkey\ LEN0068:00*500c) ACPI_EVENT stylus eject ;;
#  ibm/hotkey\ LEN0068:00*500b) ACPI_EVENT stylus replace ;;
esac


_Poweroff() {
  /sbin/shutdown -h -P now "Power button pressed"
}

# vim:set ts=4 sw=4 ft=sh et:
