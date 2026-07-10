# waybar-headset-battery

A tiny [Waybar](https://github.com/Alexays/Waybar) custom module that shows the
battery level of a wireless headset via
[HeadsetControl](https://github.com/Sapd/HeadsetControl).

Tested with a **Logitech PRO X Wireless** (`Logitech G PRO Series`), but works
with any device HeadsetControl reports a battery level for (SteelSeries Arctis,
Corsair, Razer, …).

![status](https://img.shields.io/badge/status-works%20on%20my%20machine-green)

## What it shows

| State            | Output        | CSS class                    |
|------------------|---------------|------------------------------|
| Normal           | ` 80%`       | `good` / `warning` / `critical` |
| Charging         | ` `          | `charging`                   |
| Level unknown    | ``           | `unknown` (off / standby)    |
| No headset       | ``           | `disconnected`               |
| HeadsetControl missing | (empty) | `disconnected`               |

Thresholds: `critical <= 20%`, `warning <= 40%`, otherwise `good`.
The tooltip shows the device name and exact percentage.

## Requirements

- `headsetcontrol` (Arch: `pacman -S headsetcontrol`)
- `jq`
- A Nerd Font in your Waybar (for the  glyphs)

Verify your headset is detected:

```sh
headsetcontrol -o json | jq
```

## Install

Clone it wherever you like, then symlink the script into your Waybar config
dir. Running the symlink command from inside the cloned repo keeps it
independent of the clone location:

```sh
git clone https://github.com/drumdidam/waybar-headset-battery.git
cd waybar-headset-battery
ln -sf "$PWD/headset-battery.sh" ~/.config/waybar/headset-battery.sh
```

Then add the module (see [`examples/config.jsonc`](examples/config.jsonc) and
[`examples/style.css`](examples/style.css)) and reload Waybar:

```sh
killall -SIGUSR2 waybar
```

## Configuration

```jsonc
"custom/headset": {
  "return-type": "json",
  "interval": 30,                                   // poll every 30s
  "exec": "$HOME/.config/waybar/headset-battery.sh",
  "on-click": "$HOME/.config/waybar/headset-battery.sh"  // force refresh
}
```

Don't forget to list `"custom/headset"` in one of your `modules-*` arrays.

## License

MIT — see [LICENSE](LICENSE).
