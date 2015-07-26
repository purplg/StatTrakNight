#include <sourcemod>
#include <clientprefs>
#include <smlib>

new T_TARGET, CT_TARGET;
new bool:started = false;
new round = 0;

new Handle:cookie_points;

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
	cookie_points = RegClientCookie("stattrak_points", "Track the points each client has earned", CookieAccess_Protected);
	HookEvent("cs_win_panel_match", Event_WinPanelMatch);
}

char[] format_tie_message(String:winners[], size) {
	decl String:str[255];
	if (size == 2) {
		Format(str, sizeof(str), "%s and %s", GetName(Client_FindBySteamId(winners[0])), GetName(Client_FindBySteamId(winners[1])));
	} else {
		Format(str, sizeof(str), "%s, %s", GetName(Client_FindBySteamId(winners[0])), GetName(Client_FindBySteamId(winners[1])));
		for (new i = 2; i < size-1; i++) {
			Format(str, sizeof(str), "%s, %s", str, GetName(Client_FindBySteamId(winners[i])));
		}
		Format(str, sizeof(str), "%s, and %s", str, GetName(Client_FindBySteamId(winners[size-1])));
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
	/*new cti = Array_FindHighestValue(ct_points, MAXPLAYERS);
	new ti = Array_FindHighestValue(t_points, MAXPLAYERS);
	Client_PrintToChatAll(false, "CT Winner: %s", GetName(Client_FindBySteamId(ct_steamid[cti])));
	Client_PrintToChatAll(false, "T Winner: %s", GetName(Client_FindBySteamId(t_steamid[ti])));*/
}

calculate_scores(const String:input_sids[], size, String:output_sids[], output_points[], output_size) {
	// Clear output arrays
	for (int i = 0; i < output_size; i++) {
		if (output_sids[i] == 0) break;
		output_sids[i] = 0;
		output_points[i] = 0;
	}

	// Copy input array for mutability
	new String:board[size];
	for (new i = 0; i < size; i++) {
		if (input_sids[i] == 0) break;
		board[i] = input_sids[i];
	}

	// Add up unique steamids
	output_size = 0;
	new current;
	new count;
	for (new i = 0; i < size; i++) {
		if (board[i] == 0) continue;
		current = board[i];
		count = 0;

		for (new j = i; j < size; j++) {
			if (board[i] == board[j]) {
				board[j] = 0;
				count++;
			}
		}
		output_sids[output_size] = current;
		output_points[output_size] = count;
		output_size++;
	}
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	if (started) {
		int victim_id = GetEventInt(event, "userid");
		int attacker_id = GetEventInt(event, "attacker");

		if (victim_id == attacker_id) return;
		if (!Client_IsValid(GetClientOfUserId(attacker_id))) return;

		if (GetClientOfUserId(victim_id) == CT_TARGET) {
			decl String:strBuffer[3];
			GetClientCookie(GetClientOfUserId(attacker_id), cookie_points, strBuffer, 3);
			new points = StringToInt(strBuffer) + 1;
			IntToString(points, strBuffer, 3);
			SetClientCookie(GetClientOfUserId(attacker_id), cookie_points, strBuffer);
			Client_PrintToChatAll(false, "{B}%s{N} was killed by %s! (%i points)", GetName(GetClientOfUserId(victim_id)), GetName(GetClientOfUserId(attacker_id)), points);
		} else if (GetClientOfUserId(victim_id) == T_TARGET) {
			decl String:strBuffer[3];
			GetClientCookie(GetClientOfUserId(attacker_id), cookie_points, strBuffer, 3);
			new points = StringToInt(strBuffer) + 1;
			IntToString(points, strBuffer, 3);
			SetClientCookie(GetClientOfUserId(attacker_id), cookie_points, strBuffer);
			Client_PrintToChatAll(false, "{R}%s{N} was killed by %s! (%i points)", GetName(GetClientOfUserId(victim_id)), GetName(GetClientOfUserId(attacker_id)), points);
		}
	}
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
	if (started) {
		round++;
		T_TARGET = Client_GetRandom(CLIENTFILTER_TEAMONE | CLIENTFILTER_ALIVE);
		CT_TARGET = Client_GetRandom(CLIENTFILTER_TEAMTWO | CLIENTFILTER_ALIVE);
		Beacon(T_TARGET);
		Beacon(CT_TARGET);
		Client_PrintToChatAll(false, "{B}%s{N} and \x09%s\x01 are the targets!", GetName(CT_TARGET), GetName(T_TARGET));
	}
}

bool Array_Contains(any:arr[], size, any:value) {
	for (new i = 0; i < size; i++) if (arr[i] == value)
		return true;
	return false;
}

char[] GetName(client) {
	new String:name[16];
	GetClientName(client, name, 16)
	return name;
}

Beacon(name) {
	InsertServerCommand("sm_beacon %s", GetName(name));
}
