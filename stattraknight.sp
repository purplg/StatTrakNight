#include <sourcemod>

new TEAM_T = 2;
new TEAM_CT = 3;

new bool:started;

public Plugin myinfo =
{
	name = "StatTrak Night",
	author = "Ben Whitley",
	description = "A plugin to manage StatTrak Night events",
	version = "0.1",
	url = "https://www.github.com/purplg"
};

public void OnPluginStart() {
	RegConsoleCmd("sm_stattrak", Command_StartStatTrak);
}

public Action:Command_StartStatTrak(client, args) {
	PrintToChatAll("Starting StatTrak Night...");
	started = true;
	StartBeacons();
	return Plugin_Handled;
}

StartBeacons() {
	StopBeacons();
	Beacon(GetRandomPlayerOnTeam(TEAM_CT));
	Beacon(GetRandomPlayerOnTeam(TEAM_T));
	return Plugin_Handled;
}

StopBeacons() {

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
	for ( new j = 1; j <= GetMaxClients(); j++) {
		if ( IsClientInGame(j) && IsPlayerAlive(j) && GetClientTeam(j) == team ) {
			clientids[i] = j;
			i++;
		}
	}
	new randint = GetRandomInt(0, i);
	return clientids[randint];
}
