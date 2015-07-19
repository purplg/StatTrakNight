#include <sourcemod>
#include <smlib>

new BEACON_T, BEACON_CT;
new bool:started = false;
new T_KILLERS[15];
new CT_KILLERS[15];
new round = 0;

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
	/*new killers[] = {
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		0,
		2,
		2,
		2,
		2,
		2,
		2,
		2
	}
	int w = findWinner(killers);
	Client_PrintToChatAll(false, "%i wins", w);*/
}

char[] format_tie_message(int[] winners, size) {
	new String:str[255];
	if (size == 2) {
		Format(str, 255, "%s and %s", GetName(GetClientOfUserId(winners[0])), GetName(GetClientOfUserId(winners[1])));
	} else {
		Format(str, 255, "%s, %s", GetName(GetClientOfUserId(winners[0])), GetName(GetClientOfUserId(winners[1])));
		for (new i = 2; i < size-1; i++) {
			Format(str, 255, "%s, %s", str, GetName(GetClientOfUserId(winners[i])));
		}
		Format(str, 255, "%s, and %s", str, GetName(GetClientOfUserId(winners[size-1])));
	}
	return str;
}

public Action:Command_StatTrak(client, args) {
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	if (arg1[0] != 0) {
		switch (StringToInt(arg1)) {
			case 1: {
				start();
			}
			case 0: {
				stop();
			}
		}
	} else {
		ReplyToCommand(client, "Usage: sm_stattrak [0|1]");
	}

	return Plugin_Handled;
}

start() {
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_death", Event_PlayerDeath);
	started = true;
	Client_PrintToChatAll(false, "Starting StatTrak Night next round");
}

stop() {
	Client_PrintToChatAll(false, "StatTrak Night has ended");
	started = false;
}

public void Event_WinPanelMatch(Event event, const char[] name, bool dontBroadcast) {
	started = false;
	new twinner = findWinners(T_KILLERS);
	new ctwinner = findWinners(CT_KILLERS);
	Client_PrintToChatAll(false, "T Winner: %i", twinner);
	Client_PrintToChatAll(false, "CT Winner: %i", ctwinner);
}

int findWinner(winners[], size) {
	if (size > 1) {
		Client_PrintToChatAll(false, "Tie between %s", format_tie_message(winners, size));
		new rand = Math_GetRandomInt(0, size-1);
		return winners[rand];
	}
	return winners[0];
}

findWinners(a[]) {
	new most[15];
	new mostIndex = 0;
	new mostCount = 0;
	new current;
	new count;
	for (new i = 0; i < 15; i++) {
		current = a[i];
		count = 0;
		for (new j = i; j < 15; j++) {
			if(a[j] == 0) continue;
			if (current == a[j]) {
				count++;
			}
		}
		if(count == mostCount) {
			most[++mostIndex] = a[i];
		} else if (count > mostCount) {
			Array_Fill(most, 15, 0);
			mostIndex = 0;
			most[0] = a[i];
			mostCount = count;
		}
	}
	new trimmed_most[mostIndex+1];
	Array_Copy(most, trimmed_most, mostIndex+1);
	return findWinner(trimmed_most, mostIndex+1);
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	if (started) {
		int victim_id = GetEventInt(event, "userid");
		int attacker_id = GetEventInt(event, "attacker");
		if(victim_id == attacker_id) return;
		if (GetClientOfUserId(victim_id) == BEACON_CT) {
			T_KILLERS[round-1] = GetSteamAccountID(GetClientOfUserId(attacker_id));
			Client_PrintToChatAll(false, "{B}%s{N} was killed by %s!", GetName(GetClientOfUserId(victim_id)), GetName(GetClientOfUserId(attacker_id)));
		} else if (GetClientOfUserId(victim_id) == BEACON_T) {
			CT_KILLERS[round-1] = GetSteamAccountID(GetClientOfUserId(attacker_id));
			Client_PrintToChatAll(false, "{R}%s{N} was killed by %s!", GetName(GetClientOfUserId(victim_id)), GetName(GetClientOfUserId(attacker_id)));
		}
	}
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
	if (started) {
		round++;
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
