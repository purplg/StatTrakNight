#include <sourcemod>
#include <clientprefs>
#include <smlib>
#include <sdktools>

public Plugin myinfo =
{
    name = "StatTrak Night",
    author = "Ben Whitley",
    description = "A plugin to automate StatTrak Night events",
    version = "0.9.7",
    url = "https://github.com/purplg/StatTrakNight"
};

const int TEAM_T = 2, TEAM_CT = 3;
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

public void OnPluginStart() {
    optout_players = CreateArray(32);
    scoreboard_players = CreateArray(32);
    scoreboard_points = CreateArray();

    Funcommands_OnPluginStart();
    Sounds_Load();
    Weapons_Load();

    RegAdminCmd("sm_st", Command_stattrak, ADMFLAG_SLAY, "sm_st <start|stop> [time]");
    RegAdminCmd("sm_st_points", Command_points, ADMFLAG_SLAY, "sm_st_points");
    RegAdminCmd("sm_st_optout", Command_optout, ADMFLAG_SLAY, "sm_st_optout");
    RegAdminCmd("sm_st_optin", Command_optin, ADMFLAG_SLAY, "sm_st_optin");
    RegAdminCmd("sm_st_start", Command_start, ADMFLAG_SLAY, "sm_st_start  [time]");
    RegAdminCmd("sm_st_stop", Command_stop, ADMFLAG_SLAY, "sm_st_stop [time]");
    HookEvent("round_start", Event_RoundStart);
    HookEvent("round_end", Event_RoundEnd);
    HookEvent("player_death", Event_PlayerDeath);
    HookEvent("cs_win_panel_match", Event_EndMatch);
    HookEvent("bot_takeover", Event_BotTakeover);
}

public Action Command_stattrak(int client, int args) {
	if (GetCmdArgs() == 0) {
		Scoreboard_Show(client); 
		return Plugin_Handled;
	} else {
		char arg[32];
		GetCmdArg(1, arg, sizeof(arg));

		if (StrEqual(arg, "start", false)) {
			PrintAll("Command_stattrak start");
			GetCmdArg(2, arg, sizeof(arg));
			Game_Start(client, StringToInt(arg));
			return Plugin_Handled;

		} else if (StrEqual(arg, "stop", false)) {
			GetCmdArg(1, arg, sizeof(arg));
			Game_Stop(client, StringToInt(arg));
			return Plugin_Handled;

		} else if (StrEqual(arg, "points", false)) {
			int points = Points_Get(client);
			PrintClient(client, "You have %i point%s.", points, Format_Plural(points));
		}
	}
	return Plugin_Handled;
}

public Action Command_optin(int client, int args) {
    if (Client_IsValid(client)) {
	int index = optout_players.FindValue(client);
	if (index > -1) {
	    optout_players.Erase(index);
	} else {
	    Reply(client, "You are already opted in.");
	}
    }
    return Plugin_Handled;
}

public Action Command_optout(int client, int args) {
    if (Client_IsValid(client)) {
	if (optout_players.FindValue(client) == -1) {
	    optout_players.Push(client);
	} else {
	    Reply(client, "You already opted out");
	}
    }
    return Plugin_Handled;
}

public Action Command_scoreboard(int client, int args) {
   Scoreboard_Show(client); 
   return Plugin_Handled;
}

public Action Command_points(int client, int args) {
    int points = Points_Get(client);
    PrintClient(client, "You have %i point%s.", points, Format_Plural(points));
    return Plugin_Handled;
}

public Action Command_start(int client, int args) {
    char arg_time[32];
    GetCmdArg(1, arg_time, sizeof(arg_time));
    Game_Start(client, StringToInt(arg_time));
    return Plugin_Handled;
}

public Action Command_stop(int client, int args) {
    char arg_time[32];
    GetCmdArg(1, arg_time, sizeof(arg_time));
    Game_Stop(client, StringToInt(arg_time));
    return Plugin_Handled;
}

public void OnMapEnd() {
    Funcommands_OnMapEnd();
    Game_FullStop();
}

public void OnMapStart() {
    Funcommands_OnMapStart();
    Game_Reset();
}
