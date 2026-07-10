#!/usr/bin/env bash
# Waybar custom module: headset battery via HeadsetControl
# Outputs JSON (return-type: json).
#
# Note: many wireless headsets (e.g. Logitech PRO X) do not report a
# reliable battery level while charging, so no percentage is shown then.

if ! command -v headsetcontrol >/dev/null 2>&1; then
  echo '{"text":"","tooltip":"headsetcontrol not installed","class":"disconnected"}'
  exit 0
fi

raw=$(headsetcontrol -o json 2>/dev/null || true)

if [ -z "$raw" ] || ! printf '%s' "$raw" | jq -e '(.devices // []) | length > 0' >/dev/null 2>&1; then
  echo '{"text":"","tooltip":"No headset connected","class":"disconnected"}'
  exit 0
fi

printf '%s' "$raw" | jq -c '
  .devices[0] as $d
  | ($d.battery.level  // -1)                    as $lvl
  | ($d.battery.status // "BATTERY_UNAVAILABLE") as $st
  | ($d.device // "Headset")                     as $name
  | if $st == "BATTERY_CHARGING" then
      { text: "🎧 🔌",
        tooltip: "\($name)\ncharging",
        class: "charging" }
    elif $lvl < 0 then
      { text: "🎧",
        tooltip: "\($name)\nbattery unknown (off / standby?)",
        class: "unknown" }
    else
      { text: "🎧 \($lvl)%",
        tooltip: "\($name)\nbattery: \($lvl)%",
        class: (if $lvl <= 20 then "critical"
                elif $lvl <= 40 then "warning"
                else "good" end),
        percentage: $lvl }
    end'
