#!/usr/bin/env sh

# NOTE: _runner already define some commons, if definition is not here
# probably its on _runner.

_get_status() {
    mic_enable=0
    mic_volume=$(wpctl get-volume @DEFAULT_SOURCE@ | sed -ne 's/.*\([0-9]\.[0-9]\{2\}\).*/\1/p')

    speaker_enable=0
    speaker_volume=$(wpctl get-volume @DEFAULT_SINK@ | sed -ne 's/.*\([0-9]\.[0-9]\{2\}\).*/\1/p')

    if [ -z "$(wpctl get-volume @DEFAULT_SOURCE@ | sed -ne 's/.*\(MUTED\).*/\1/p')" ]; then
        mic_enable=1
    fi

    if [ -z "$(wpctl get-volume @DEFAULT_SINK@ | sed -ne 's/.*\(MUTED\).*/\1/p')" ]; then
        speaker_enable=1
    fi

    printf '{'

    # Speaker
    printf '"speaker": {'
    printf '"enable": %s,' $speaker_enable
    printf '"volume": %s' $speaker_volume
    printf '},'

    # Microphone
    printf '"microphone": {'
    printf '"enable": %s,' $mic_enable
    printf '"volume": %s' $mic_volume
    printf '}'

    printf '}\n'
}

case $1 in
    status)
        _get_status
        ;;

    speaker | microphone)
        target="@DEFAULT_SINK@"
        if [ "$1" = 'microphone' ]; then
            target="@DEFAULT_SOURCE@"
        fi

        case $2 in
            set)
                signal=$(echo $3 | sed -ne 's/\([-|+]*\).*/\1/p')
                value=$(echo $3 | sed -ne 's/[^0-9]*\([0-9]*\).*/\1/p')
                percent=$(echo $3 | sed -ne 's/.*%/%/p')

                # Normalize if above 1.0
                if [ -z "$percent" -a "$value" -gt 1 ]; then
                    int=$(( $value / 100 ))
                    dec=$(( ${value}00 / 100 ))

                    if [ ${#dec} -lt 2 ]; then
                        dec="0$dec"
                    fi

                    value=$int.$(echo $dec | sed -e 's/.\([0-2]\)\{2\}$/\1/')
                fi

                wpctl set-volume --limit 1.0 $target $value$percent$signal
                ;;

            get)
                echo $(wpctl get-volume $target | sed -ne 's/.*\([0-9]\.[0-9]\{2\}\).*/\1/p')
                ;;

            toggle-mute)
                wpctl set-mute $target toggle
                ;;
        esac
        ;;
esac
