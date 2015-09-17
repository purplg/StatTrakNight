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

#### Show how many points you have earned
> **Note**: This will be replaced by a scoreboard in the future

| Command 						| Action 									|
|-------------------------------|-------------------------------------------|
| sm_stattrak					| Shows your points							|
| sm_stattrak_start [seconds]	| Start on next round or after # [seconds]	|
| sm_stattrak_stop [seconds]	| Stop on next round or after # [seconds]	|

# License

This project is licensed under the MIT License

Full license can be viewed [here](LICENSE).
