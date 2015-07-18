#include <sourcemod>

new const TEAM_T = 2;
new const TEAM_CT = 3;

new BEACON_T, BEACON_CT;
new bool:started = false;
new String:T_KILLERS[15];
new String:CT_KILLERS[15];

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
	BEACON_T = GetRandomPlayerOnTeam(TEAM_T);
	BEACON_CT = GetRandomPlayerOnTeam(TEAM_CT);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_death", Event_PlayerDeath);
	started = true;
	PrintToChatAll("Starting StatTrak Night next round");
}

stop(client) {
	PrintToChatAll("StatTrak Night has ended");
	started = false;
}

public void Event_WinPanelMatch(Event event, const char[] name, bool dontBroadcast) {
	PrintToChatAll("");
	started = false;
}
public void Event_MatchEndRestart(Event event, const char[] name, bool dontBroadcast) {
	PrintToChatAll("MatchEndRestart");
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	if (started) {
		int victim_id = GetEventInt(event, "userid");
		int attacker_id = GetEventInt(event, "attacker");
		if (victim_id == BEACON_CT) {
			PrintToChatAll(" \x06%s\x01 was killed by %s!", GetName(victim_id), GetName(attacker_id));
		} else if (victim_id == BEACON_T) {
			PrintToChatAll(" \x02%s\x01 was killed by %s!", GetName(victim_id), GetName(attacker_id));
		}
	}
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
	if (started) {
		Beacon(BEACON_T);
		Beacon(BEACON_CT);
		PrintToChatAll("\x08%s\x01 and \x02%s\x01 are the targets!", GetName(BEACON_CT), GetName(BEACON_T));
	}
}

char[] GetName(userid) {
	new String:name[16]
	GetClientName(GetClientOfUserId(userid), name, 16)
	return name;
}

int GetRandomPlayerOnTeam(team) {
	new ids[GetClientCount()];
	new i = 0;
	for ( new j = 1; j <= GetMaxClients(); j++ ) {
		if ( IsClientInGame(j) && IsPlayerAlive(j) && GetClientTeam(j) == team ) {
			ids[i] = j;
			i++;
		}
	}
	new randint = GetRandomInt(0, i-1);
	PrintToChatAll("randint: %i, ids: %i", randint, ids[randint]);
	return GetClientUserId(ids[randint]);
}

Beacon(name) {
	InsertServerCommand("sm_beacon %s", GetName(name));
}
