#!/bin/bash
#
# ledctl -- analog-stick RGB LED control for AISLPC RK3562 handhelds
#           (RG52 Mini / RG43H Pro / RG43V Pro).
#
# The LEDs are driven by a small on-board controller on uart1 (/dev/ttyS1).
# Protocol reverse-engineered from the stock "mcu_led" binary AND the
# manufacturer's (corrected) mcu_led_ctrl.sh:
#
#   * line: open ONCE, write-only, CLOCAL, 9600 8N1 raw.
#   * each value = one byte, written REPEAT times, ~10ms apart.
#   * REQUIRED handshake: send "init <ledcount>" ONCE after power-up before
#     the controller will accept mode/brightness. The firmware we originally
#     dumped skipped this (it only sent bri/chgmode) -- which is why the LEDs
#     ignored every command and just ran the power-on rainbow. The
#     manufacturer's correct script sends `init 12 6` first.
#
#   byte mapping (from the mcu_led binary: 4->0x20, 8->0x21, i.e.
#   byte = 0x20 + ledcount/4 - 1):
#     init <ledcount> -> 0x20 + ledcount/4 - 1   (12 LEDs -> 0x22)
#     chgmode N       -> byte N  (1=G 2=B 3=R 4=G+B 5=R+G 6=B+R 7=rainbow
#                                 8=scroll 9=OFF ; 17-24 breathing)
#     bri B           -> byte (50 - B)
#
# NOTE: the init byte for 12 LEDs (0x22) is inferred from the 4/8 mapping; if
# the manufacturer's newer binary uses a different value, change LEDCOUNT or
# the formula in init_byte(). Our shipped mcu_led binary only knows 4/8, so we
# write the byte ourselves rather than shelling out to it.
#
# Rail power: vcc-led (GPIO0_C7) via the regulator debugfs "enable" knob.
# OFF at boot; LEDs stay dark until the user opts in.
#
# Persistence: /home/ark/.config/led.cfg (ENABLED/MODE/BRI/LEDCOUNT).
# Must run as root (debugfs + tty). The UI calls it via sudo.

LED_DEV=/dev/ttyS1
LED_PWR=/sys/kernel/debug/regulator/vcc-led/enable
CFG=/home/ark/.config/led.cfg

# Defaults -- OFF, solid red, mid brightness, 12-LED chain (per manufacturer).
ENABLED=0
MODE=3
BRI=5
LEDCOUNT=12
REPEAT=6        # how many times each byte is sent (manufacturer uses 6)

# shellcheck source=/dev/null
[ -f "$CFG" ] && . "$CFG"

# No controller UART on this unit (uart1 disabled / not equipped) -> no-op.
[ -e "$LED_DEV" ] || exit 0

# init handshake byte for the configured LED count, or "" to skip.
init_byte() {
	case "$LEDCOUNT" in
		''|*[!0-9]*) return 1 ;;            # not numeric -> skip
	esac
	[ "$LEDCOUNT" -ge 4 ] || return 1
	echo $((0x20 + LEDCOUNT / 4 - 1))
}

pwr() { [ -w "$LED_PWR" ] && printf '%s' "$1" > "$LED_PWR" 2>/dev/null; }

# Open the controller UART once on fd 9, write-only, CLOCAL, raw.
open_uart() {
	stty -F "$LED_DEV" 9600 cs8 -cstopb -parenb clocal -crtscts -ixon raw -echo 2>/dev/null
	exec 9>"$LED_DEV" 2>/dev/null
}
close_uart() { exec 9>&- 2>/dev/null; }

# Send one byte (decimal) REPEAT times on the held-open fd, ~10ms apart.
send() {
	local oct i=0
	oct=$(printf '%03o' "$1")
	while [ "$i" -lt "$REPEAT" ]; do
		printf "\\$oct" >&9 2>/dev/null
		sleep 0.01
		i=$((i + 1))
	done
}

save() {
	mkdir -p "$(dirname "$CFG")"
	printf 'ENABLED=%s\nMODE=%s\nBRI=%s\nLEDCOUNT=%s\n' \
		"$ENABLED" "$MODE" "$BRI" "$LEDCOUNT" > "$CFG"
	chown ark:ark "$CFG" 2>/dev/null
}

light_on() {
	pwr 1
	open_uart || return
	local ib
	if ib=$(init_byte); then send "$ib"; sleep 0.1; fi   # init <ledcount> first
	send "$MODE"
	sleep 0.05
	send $((50 - BRI))
	close_uart
}

light_off() {
	open_uart || { pwr 0; return; }
	send 9              # chgmode 9 = OFF
	close_uart
	pwr 0               # drop the rail
}

case "$1" in
	apply)   [ "$ENABLED" = "1" ] && light_on || light_off ;;
	on)      ENABLED=1; save; light_on ;;
	off)     ENABLED=0; save; light_off ;;
	mode)    MODE=${2:-$MODE}; save; [ "$ENABLED" = "1" ] && light_on ;;
	bri)     BRI=${2:-$BRI};   save; [ "$ENABLED" = "1" ] && light_on ;;
	count)   LEDCOUNT=${2:-$LEDCOUNT}; save; [ "$ENABLED" = "1" ] && light_on ;;
	suspend) light_off ;;
	# Debug: send arbitrary byte(s) on a freshly opened port. e.g. ledctl raw 34 3
	raw)     shift; pwr 1; open_uart || exit 1; for b in "$@"; do send "$b"; done; close_uart ;;
	status)  printf 'ENABLED=%s MODE=%s BRI=%s LEDCOUNT=%s (init byte=%s)\n' \
			"$ENABLED" "$MODE" "$BRI" "$LEDCOUNT" "$(init_byte || echo none)" ;;
	*)       echo "usage: ledctl {apply|on|off|mode N|bri B|count C|suspend|raw B...|status}" >&2; exit 2 ;;
esac
