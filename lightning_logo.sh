#!/bin/bash

LOGO_FILE="${1:-$(dirname "$(readlink -f "$0")")/lightning_ascii_logo}"
[ -f "$LOGO_FILE" ] || exit 0

export LC_ALL=C.UTF-8 2>/dev/null

RESET="\e[0m"
if [[ "$COLORTERM" == *truecolor* || "$COLORTERM" == *24bit* ]]; then TRUECOLOR=1; else TRUECOLOR=0; fi

fg() {
    if [ "$TRUECOLOR" -eq 1 ]; then FG="\e[38;2;$1;$2;$3m"
    else FG="\e[38;5;$(( 16 + 36*($1*5/255) + 6*($2*5/255) + ($3*5/255) ))m"; fi
}

STOPS_T=(0   400 750 1000)
STOPS_R=(255 255 255 255)
STOPS_G=(120 175 215 245)
STOPS_B=(0   0   20  80)

grad() {
    local t=$1 i
    [ "$t" -lt 0 ] && t=0; [ "$t" -gt 1000 ] && t=1000
    for i in 0 1 2; do [ "$t" -le "${STOPS_T[$((i+1))]}" ] && break; done
    local t0=${STOPS_T[$i]} span=$(( STOPS_T[i+1] - STOPS_T[i] )) d=$(( t - STOPS_T[i] ))
    fg $(( STOPS_R[i] + (STOPS_R[i+1]-STOPS_R[i])*d/span )) \
       $(( STOPS_G[i] + (STOPS_G[i+1]-STOPS_G[i])*d/span )) \
       $(( STOPS_B[i] + (STOPS_B[i+1]-STOPS_B[i])*d/span ))
}

tput civis 2>/dev/null
trap 'tput cnorm 2>/dev/null; echo -ne "\e[0m"' EXIT
trap 'exit 130' INT TERM

mapfile -t LINES_ARR < "$LOGO_FILE"
ROWS=${#LINES_ARR[@]}
WIDTH=${#LINES_ARR[0]}
COLS=$(tput cols 2>/dev/null || echo 80)

if [ "$COLS" -lt "$WIDTH" ]; then
    grad 500; echo -e "${FG}⚡ LightningOS${RESET}"
else
    for (( r=0; r<ROWS; r++ )); do
        line="${LINES_ARR[$r]}"; n=${#line}; out=""
        for (( c=0; c<n; c++ )); do
            ch="${line:c:1}"
            if [ "$ch" = " " ]; then out+=" "; else
                grad $(( (c*800/(n-1)) + ((ROWS-1-r)*200/(ROWS-1)) ))
                out+="${FG}${ch}"
            fi
        done
        echo -e "${out}${RESET}"
        sleep 0.05
    done
fi

echo ""

fg 0 229 255; echo -ne "\e[1m${FG}Initializing LIGHTNINGOS Build Environment"
for i in {1..5}; do
    grad $(( i*200 )); echo -ne "${FG}."
    sleep 0.4
done
echo -e "${RESET}"
fg 60 255 120; echo -e "\e[1m${FG}⚡ Ready to Compile/Build!${RESET}"