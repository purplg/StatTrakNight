#include <sourcemod>

new const TEAM_T = 2;
new const TEAM_CT = 3;

new BEACON_T, BEACON_CT;
new bool:started = false;

public Plugin myinfo =
{
	name = "StatTrak Night",
	author = "Ben Whitley",
	description = "A plugin to manage StatTrak Night events",
	version = "0.1",
	url = "https://www.github.com/purplg"
};

public void OnPluginStart() {
	HookEvent("round_start", Event_RoundStart);
	RegConsoleCmd("sm_stattrak", Command_StartStatTrak);
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
	if (started) {
		StartBeacons();
	}
}

public Action:Command_StartStatTrak(client, args) {
	PrintToChatAll("Starting StatTrak Night next round");
	BEACON_T = GetRandomPlayerOnTeam(TEAM_T);
	BEACON_CT = GetRandomPlayerOnTeam(TEAM_CT);
	started = true;
	return Plugin_Handled;
}

StartBeacons() {
	Beacon(BEACON_T);
	Beacon(BEACON_CT);
	return Plugin_Handled;
}

char[] GetName(client) {
	new String:name[16]
	GetClientName(client, name, 16)
	return name;
}

Beacon(name) {
	InsertServerCommand("sm_beacon %s", GetName(name));
}

int GetRandomPlayerOnTeam(team) {
	new clientids[GetClientCount()];
	new i = 0;
	for ( new j = 1; j <= GetMaxClients(); j++ ) {
		if ( IsClientInGame(j) && IsPlayerAlive(j) && GetClientTeam(j) == team ) {
			clientids[i] = j;
			i++;
		}
	}
	new randint = GetRandomInt(0, i-1);
	return clientids[randint];
}
