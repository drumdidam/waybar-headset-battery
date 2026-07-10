#!/usr/bin/env bash
# Waybar custom module: headset battery via HeadsetControl
# Outputs JSON (return-type: json).
#
# Icons are Nerd Font glyphs, built from their UTF-8 bytes via printf so this
# source file stays pure ASCII (some editors strip raw Private-Use-Area chars):
#   U+F025 headphones -> \xef\x80\xa5      U+F1E6 plug -> \xef\x87\xa6
# Add a Nerd Font to your Waybar font-family fallback, e.g.
#   font-family: 'YourFont', 'JetBrainsMono Nerd Font', monospace;
#
# Note: many wireless headsets (e.g. Logitech PRO X) do not report a
# reliable battery level while charging, so no percentage is shown then.

ICON_HP=$(printf '\xef\x80\xa5')    # U+F025 headphones
ICON_PLUG=$(printf '\xef\x87\xa6')  # U+F1E6 plug

if ! command -v headsetcontrol >/dev/null 2>&1; then
  echo '{"text":"","tooltip":"headsetcontrol not installed","class":"disconnected"}'
  exit 0
fi

raw=$(headsetcontrol -o json 2>/dev/null || true)

if [ -z "$raw" ] || ! printf '%s' "$raw" | jq -e '(.devices // []) | length > 0' >/dev/null 2>&1; then
  echo '{"text":"","tooltip":"No headset connected","class":"disconnected"}'
  exit 0
fi

printf '%s' "$raw" | jq -c --arg hp "$ICON_HP" --arg plug "$ICON_PLUG" '
  .devices[0] as $d
  | ($d.battery.level  // -1)                    as $lvl
  | ($d.battery.status // "BATTERY_UNAVAILABLE") as $st
  | ($d.device // "Headset")                     as $name
  | if $st == "BATTERY_CHARGING" then
      { text: "\($hp) \($plug)",
        tooltip: "\($name)\ncharging",
        class: "charging" }
    elif $lvl < 0 then
      { text: $hp,
        tooltip: "\($name)\nbattery unknown (off / standby?)",
        class: "unknown" }
    else
      { text: "\($hp) \($lvl)%",
        tooltip: "\($name)\nbattery: \($lvl)%",
        class: (if $lvl <= 20 then "critical"
                elif $lvl <= 40 then "warning"
                else "good" end),
        percentage: $lvl }
    end'
