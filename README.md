# StatTrak Night

A CS:GO plugin for automating [GreatDivideGaming](https://www.greatdividegaming.com/)'s CS:GO StatTrak Night event.

# Requirements

- CS:GO Server running SourceMod

# Download

Go to the [Releases](https://github.com/purplg/StatTrakNight/releases) section to download the latest `stattraknight.smx`.

# Installation

1. Start in the CS:GO server's root directory then navigate to `csgo/addons/sourcemod/plugins/`
2. Drop the `stattraknight.smx` file there.
3. Either run `sm plugins refresh` in the CS:GO console or restart the CS:GO server.

# Usage

> **Note:** Just like most SourceMod plugins, `sm_statrak` in console is the equivalent of `!stattrak` and `/stattrak` in chat. The only difference is that the `!` shows up in chat while the `/` does not.

`sm_stattrak [0/1/start/stop] [seconds]`

#### Show how many points you have earned
> **Note**: This will be replaced by a scoreboard in the future

`sm_stattrak`

#### Start an event on next round

`sm_stattrak 1` or `sm_stattrak start`

#### Stop an event on next round

`sm_stattrak 0` or `sm_stattrak stop`

#### Start or stop event after 5 seconds

`sm_stattrak start 5` or `sm_stattrak 0 5`

# License

This project is licensed under the MIT License

Full license can be viewed [here](LICENSE).
