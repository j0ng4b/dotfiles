## Android Emulator
function emu() {
    local action="${1:-list}"
    local help_message='Android Emulator helper
Usage:
    emu <command>

Commands:
  list
      List all installed Android Virtual Devices.
      This is also the default command when no argument is provided.

  start <avd> [options]
      Start an Android Virtual Device in the background.
      Additional arguments are passed directly to the Android Emulator.

  stop [avd|serial]
      Stop a running emulator.

      The target can be either an AVD name or an emulator serial.

      If no target is provided, adb selects the only running emulator.
      When multiple emulators are running, specify a name or serial.

  status
      List running emulators with their AVD names and serial numbers.

  help
      Show this help message.

Custom environment variables:
  ANDROID_EMULATOR_MEMORY
      Amount of RAM assigned to the emulator, in MB.
      Default: 3072.

  ANDROID_EMULATOR_CORES
      Number of virtual CPU cores assigned to the emulator.
      Default: 4.

  These variables are specific to this helper function and are not
  official Android SDK environment variables.'

    (( $# > 0 )) && shift

    case "$action" in
        start)
            local avd="${1:-}"

            if [[ -z "$avd" ]]; then
                print -u2 "Missing AVD name."
                print -u2 "Run 'emu help' for usage."
                return 2
            fi

            local memory="${ANDROID_EMULATOR_MEMORY:-3072}"
            local cores="${ANDROID_EMULATOR_CORES:-4}"

            shift

            QT_QPA_PLATFORM=xcb command emulator "@$avd" \
                -gpu host \
                -memory "$memory" \
                -cores "$cores" \
                -no-boot-anim \
                "$@" >/dev/null 2>&1 &!
            ;;

        stop)
            local target="${1:-}"

            if [[ -z "$target" ]]; then
                command adb -e emu kill
                return
            fi

            if [[ "$target" == emulator-* ]]; then
                command adb -s "$target" emu kill
                return
            fi

            local serial avd

            for serial in ${(f)"$(
                command adb devices |
                    command awk \
                        'NR > 1 && $1 ~ /^emulator-/ && $2 == "device" { print $1 }'
            )"}; do
                avd="$(
                    command adb -s "$serial" emu avd name 2>/dev/null |
                        command sed -n '1p'
                )"
                avd="${avd//$'\r'/}"

                if [[ "$avd" == "$target" ]]; then
                    command adb -s "$serial" emu kill
                    return
                fi
            done

            print -u2 "Emulator not running: $target"
            return 1
            ;;

        status)
            local serial avd
            local found=0

            print -f "%-20s %s\n" "AVD" "SERIAL"

            for serial in ${(f)"$(
                command adb devices |
                    command awk \
                        'NR > 1 && $1 ~ /^emulator-/ && $2 == "device" { print $1 }'
            )"}; do
                avd="$(
                    command adb -s "$serial" emu avd name 2>/dev/null |
                        command sed -n '1p'
                )"
                avd="${avd//$'\r'/}"

                print -f "%-20s %s\n" "$avd" "$serial"
                found=1
            done

            (( found )) || print "No emulators running."
            ;;

        list)
            command emulator -list-avds
            ;;

        help|-h|--help)
            print -r -- "$help_message"
            ;;

        *)
            print -u2 "Unknown command: $action"
            print -u2
            print -ru2 -- "$help_message"
            return 2
            ;;
    esac
}
