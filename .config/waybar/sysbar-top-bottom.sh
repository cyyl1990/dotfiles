#!/usr/bin/env bash

# giảm race condition khi interval thấp
sleep 0.05

STATE="/tmp/waybar_sysbar"
[ ! -f "$STATE" ] && echo "cpu" > "$STATE"

mode=$(cat "$STATE")

# ---- SCROLL ----
if [ "$1" = "up" ]; then
    case $mode in
        cpu) echo "mem" > "$STATE" ;;
        mem) echo "swap" > "$STATE" ;;
        swap) echo "cpu" > "$STATE" ;;
    esac
    mode=$(cat "$STATE")
fi

if [ "$1" = "down" ]; then
    case $mode in
        cpu) echo "swap" > "$STATE" ;;
        mem) echo "cpu" > "$STATE" ;;
        swap) echo "mem" > "$STATE" ;;
    esac
    mode=$(cat "$STATE")
fi

# ---- BAR ----
make_bar(){
    percent=${1:-0}

    filled=$((percent / 12))
    empty=$((8 - filled))

    bar=""

    for ((i=0;i<filled;i++)); do
        bar+=""
    done

    for ((i=0;i<empty;i++)); do
        bar+=""
    done

    echo "$bar"
}

# ---- CPU ----
cpu=$(grep 'cpu ' /proc/stat | awk '{print int(($2+$4)*100/($2+$4+$5))}')

# ---- MEM ----
read MEM_TOTAL MEM_AVAIL <<<$(awk '
/MemTotal/ {t=$2}
/MemAvailable/ {a=$2}
END {print t, a}
' /proc/meminfo)

mem=$(( (MEM_TOTAL - MEM_AVAIL) * 100 / MEM_TOTAL ))

# ---- SWAP ----
swap=$(awk '
/SwapTotal/ {t=$2}
/SwapFree/ {f=$2}
END {
    if(t==0){print 0}
    else {print int((t-f)*100/t)}
}
' /proc/meminfo)

# ---- OUTPUT ----
case $mode in

cpu)
    bar=$(make_bar "$cpu")
    printf '{"text":"[cpu %2d%% %s ]"}\n' "${cpu:-0}" "$bar"
;;

mem)
    bar=$(make_bar "$mem")
    printf '{"text":"[mem %2d%% %s ]"}\n' "${mem:-0}" "$bar"
;;

swap)
    bar=$(make_bar "$swap")
    printf '{"text":"[swap %2d%% %s ]"}\n' "${swap:-0}" "$bar"
;;

esac
