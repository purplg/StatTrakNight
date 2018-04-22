#include <sourcemod>
#include <clientprefs>
#include <smlib>
#include <sdktools>

public Plugin myinfo =
{
	name = "StatTrak Night",
	author = "Ben Whitley",
	description = "A plugin to automate StatTrak Night events",
	version = "0.9.8",
	url = "https://github.com/purplg/StatTrakNight"
};

const int T_TEAM = 2, CT_TEAM = 3;
int T_TARGET, CT_TARGET;
bool starting, stopping, running;

ArrayList optout_players;
ArrayList scoreboard_players;
ArrayList scoreboard_points;

#include "stattraknight/beacon/funcommands.sp"
#include "stattraknight/format.sp"
#include "stattraknight/game.sp"
#include "stattraknight/clients.sp"
#include "stattraknight/weapons.sp"
#include "stattraknight/points.sp"
#include "stattraknight/sounds.sp"
#include "stattraknight/events.sp"
#include "stattraknight/announcements.sp"
#include "stattraknight/scoreboard.sp"
#include "stattraknight/commands.sp"

public void OnPluginStart() {
	optout_players = CreateArray(32);
	scoreboard_players = CreateArray(32);
	scoreboard_points = CreateArray();

	Funcommands_OnPluginStart();
	Sounds_Load();
	Weapons_Load();

	RegAdminCmd("sm_st", Command_stattrak, ADMFLAG_SLAY, "sm_st <start|stop> [time]");
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("cs_win_panel_match", Event_EndMatch);
	HookEvent("bot_takeover", Event_BotTakeover);
}

public void OnMapEnd() {
	Funcommands_OnMapEnd();
	Game_FullStop();
}

public void OnMapStart() {
	Funcommands_OnMapStart();
	Game_Reset();
}
