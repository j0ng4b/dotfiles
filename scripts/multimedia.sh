#!/usr/bin/env sh

# NOTE: _runner already define some commons, if definition is not here
# probably its on _runner.

# Cache
cache_dir=$SCRIPT_CACHE_DIR

cache_dir_player=$cache_dir/player
cache_player_cover=$cache_dir_player/cover
cache_player_current=$cache_dir_player/current

if [ -z "$cache_dir" ]; then
    exit 1
elif [ ! -d "$cache_dir" ]; then
    mkdir -p $cache_dir
    mkdir -p $cache_dir_player

    touch $cache_player_cover
    touch $cache_player_current
fi

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

# Player
_player_exist() {
    players=$(_player_list)
    if [ -z "$players" ]; then
        return 1
    fi

    player=$1
    if [ -z "$player" ]; then
        return 1
    elif ! str_contains "$players" "$player"; then
        return 1
    else
        return 0
    fi
}

_player_get_icon() {
    player=$1
    case $player in
        firefox)
            echo '󰈹'
            ;;

        mpv)
            echo ''
            ;;

        spotify)
            echo '󰓇'
            ;;

        *)
            echo ''
            ;;
    esac
}

_player_subscribe() {
    while true; do
        player=$(cat $cache_player_current)
        if ! _player_exist "$player"; then
            player="%any"
        fi

        raw_data=$(playerctl metadata --player=$player --format '{{playerName}}@{{title}}@{{artist}}@{{mpris:artUrl}}@{{lc(status)}}@{{mpris:length}}@{{duration(mpris:length)}}@{{position}}@{{duration(position)}}' 2>/dev/null)

        name=$(echo $raw_data | cut -d@ -f1)
        title=$(echo $raw_data | cut -d@ -f2)
        artist=$(echo $raw_data | cut -d@ -f3)
        cover=$(echo $raw_data | cut -d@ -f4)
        status=$(echo $raw_data | cut -d@ -f5)
        length=$(echo $raw_data | cut -d@ -f6)
        length_time=$(echo $raw_data | cut -d@ -f7)
        position=$(echo $raw_data | cut -d@ -f8)
        position_time=$(echo $raw_data | cut -d@ -f9)

        if [ -n "$length" ]; then
            length=$(( $length / 1000000 ))
            position=$(( $position / 1000000 ))
        fi

        if [ -z "$cover" ]; then
            cover=
        elif str_contains "$cover" "file://"; then
            cover=$(echo "$cover" | sed -ne 's/file:\/\///gp')
        else
            curl --silent $cover --output $cache_player_cover
            cover=$cache_player_cover
        fi

        data=$(jq --null-input \
            --compact-output \
            --arg name "$name" \
            --arg icon "$(_player_get_icon $name)" \
            --arg title "$title" \
            --arg artist "$artist" \
            --arg cover "$cover" \
            --arg status "$status" \
            --arg position "$position" \
            --arg length "$length" \
            --arg pos_time "$position_time" \
            --arg len_time "$length_time" \
            '{name: $name, icon: $icon, title: $title, artist: $artist, cover: $cover, status: $status, position: $position, time: $pos_time, length: $length, duration: $len_time }')

        echo $data
        sleep 1s
    done
}

_player_set_position() {
    signal=$(echo $1 | sed -ne 's/\([-|+]*\).*/\1/p')
    value=$(echo $1 | sed -ne 's/[^0-9]*\([0-9]*\).*/\1/p')

    player=$(cat $cache_player_current)
    if ! _player_exist "$player"; then
        player="%any"
    fi

    playerctl position --player=$player $value$signal 2>/dev/null
}

_player_list() {
    players=''

    for player in $(playerctl --list-all 2>/dev/null); do
        players="$players$(echo $player | sed -ne 's/\([a-zA-Z0-9]\+\)\(\..\+\)*$/\1/p')\n"
    done

    echo $players
}

cmd=$1
case $cmd in
    status)
        _get_status
        ;;

    player)
        subcmd=$2
        case $subcmd in
            subscribe)
                _player_subscribe
                ;;

            set-position)
                _player_set_position $3
                ;;

            next | previous)
                player=$(cat $cache_player_current)
                if ! _player_exist "$player"; then
                    player="%any"
                fi

                playerctl $subcmd --player=$player 2>/dev/null
                ;;

            play | pause)
                player=$(cat $cache_player_current)
                if ! _player_exist "$player"; then
                    player="%any"
                fi

                playerctl $subcmd --player=$player 2>/dev/null
                ;;

            toggle-play)
                player=$(cat $cache_player_current)
                if ! _player_exist "$player"; then
                    player="%any"
                fi

                playerctl play-pause --player=$player 2>/dev/null
                ;;

            list)
                _player_list
                ;;

            *)
                error "Unknown command '$subcmd'!"
                exit 1
                ;;
        esac
        ;;

    speaker | microphone)
        target="@DEFAULT_SINK@"
        if [ "$cmd" = 'microphone' ]; then
            target="@DEFAULT_SOURCE@"
        fi

        subcmd=$2
        case $subcmd in
            lower)
                wpctl set-volume --limit 1.0 $target 5%-
                ;;

            raise)
                wpctl set-volume --limit 1.0 $target 5%+
                ;;

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

            *)
                error "Unknown command '$subcmd'!"
                exit 1
                ;;
        esac
        ;;

    *)
        error "Unknown command '$cmd'!"
        exit 1
        ;;
esac

