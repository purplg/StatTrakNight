#include <sourcemod>
#include <smlib>

new const TEAM_T = 2;
new const TEAM_CT = 3;

new BEACON_T, BEACON_CT;
new bool:started = false;
new String:T_KILLERS[14];
new String:CT_KILLERS[14];

public Plugin myinfo =
{
	name = "StatTrak Night",
	author = "Ben Whitley",
	description = "A plugin to manage StatTrak Night events",
	version = "0.1",
	url = "https://www.github.com/purplg"
};

public void OnPluginStart() {
	RegConsoleCmd("sm_stattrak", Command_StatTrak);
	HookEvent("cs_win_panel_match", Event_WinPanelMatch);
	HookEvent("cs_match_end_restart", Event_MatchEndRestart);
}

public Action:Command_StatTrak(client, args) {
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	if (arg1[0] != 0) {
		switch (StringToInt(arg1)) {
			case 1: {
				start(client);
			}
			case 0: {
				stop(client);
			}
		}
	} else {
		ReplyToCommand(client, "Usage: sm_stattrak [0|1]");
	}

	return Plugin_Handled;
}

start(client) {
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_death", Event_PlayerDeath);
	started = true;
	Client_PrintToChatAll(false, "Starting StatTrak Night next round");
}

stop(client) {
	Client_PrintToChatAll(false, "StatTrak Night has ended");
	started = false;
}

public void Event_WinPanelMatch(Event event, const char[] name, bool dontBroadcast) {
	started = false;
}
public void Event_MatchEndRestart(Event event, const char[] name, bool dontBroadcast) {
	Client_PrintToChatAll(false, "MatchEndRestart");
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	if (started) {
		int victim_id = GetEventInt(event, "userid");
		int attacker_id = GetEventInt(event, "attacker");
		if(victim_id == attacker_id) return;
		if (GetClientOfUserId(victim_id) == BEACON_CT) {
			Client_PrintToChatAll(false, "{B}%s{N} was killed by %s!", GetName(GetClientOfUserId(victim_id)), GetName(GetClientOfUserId(attacker_id)));
		} else if (GetClientOfUserId(victim_id) == BEACON_T) {
			Client_PrintToChatAll(false, "{R}%s{N} was killed by %s!", GetName(GetClientOfUserId(victim_id)), GetName(GetClientOfUserId(attacker_id)));
		}
	}
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
	if (started) {
		BEACON_T = Client_GetRandom(CLIENTFILTER_TEAMONE | CLIENTFILTER_ALIVE);
		BEACON_CT = Client_GetRandom(CLIENTFILTER_TEAMTWO | CLIENTFILTER_ALIVE);
		Beacon(BEACON_T);
		Beacon(BEACON_CT);
		Client_PrintToChatAll(false, "{B}%s{N} and \x09%s\x01 are the targets!", GetName(BEACON_CT), GetName(BEACON_T));
	}
}

char[] GetName(client) {
	new String:name[16];
	GetClientName(client, name, 16)
	return name;
}

Beacon(name) {
	InsertServerCommand("sm_beacon %s", GetName(name));
}
