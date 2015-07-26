#include <sourcemod>
#include <clientprefs>
#include <smlib>

new T_TARGET, CT_TARGET;
new bool:started = false;
new round = 0;

new event_starttime;

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
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("cs_win_panel_match", Event_WinPanelMatch);
	cookie_points = RegClientCookie("stattrak_points", "The points each client has earned", CookieAccess_Protected);
}

public void OnClientCookiesCached(client) {
	if (started) {
		decl String:strBuffer[3];
		GetClientCookie(Client_FindByName("PurplG"), cookie_points, strBuffer, 3);
		if (GetClientCookieTime(Client_FindByName("PurplG"), cookie_points) < event_starttime) {
			SetClientCookie(Client_FindByName("PurplG"), cookie_points, "0");
		}
	}
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
	event_starttime = GetTime();
	started = true;
	Client_PrintToChatAll(false, "Starting StatTrak Night next round");
}

stop() {
	started = false;
	for (new i = 1; i < Client_GetCount(); i++) {
		SetClientCookie(i, cookie_points, "0");
	}
	Client_PrintToChatAll(false, "StatTrak Night has ended");
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

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	if (started) {
		int victim = GetClientOfUserId(GetEventInt(event, "userid"));
		int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

		if (victim == attacker) return;
		if (!Client_IsValid(attacker)) return;

		if (victim == CT_TARGET) {
			new points = addPoint(attacker);
			Client_PrintToChatAll(false, "{B}%s{N} was killed by %s! (%i points)",
				GetName(victim), GetName(attacker), points);
		} else if (victim == T_TARGET) {
			new points = addPoint(attacker);
			Client_PrintToChatAll(false, "{R}%s{N} was killed by %s! (%i points)",
				GetName(victim), GetName(attacker), points);
		}
	}
}

public void Event_WinPanelMatch(Event event, const char[] name, bool dontBroadcast) {
	if (started) {
		stop();
	}
	/*new cti = Array_FindHighestValue(ct_points, MAXPLAYERS);
	new ti = Array_FindHighestValue(t_points, MAXPLAYERS);
	Client_PrintToChatAll(false, "CT Winner: %s", GetName(Client_FindBySteamId(ct_steamid[cti])));
	Client_PrintToChatAll(false, "T Winner: %s", GetName(Client_FindBySteamId(t_steamid[ti])));*/
}

int addPoint(client) {
	decl String:strBuffer[3];
	GetClientCookie(client, cookie_points, strBuffer, 3);
	new points = StringToInt(strBuffer) + 1;
	IntToString(points, strBuffer, 3);
	SetClientCookie(client, cookie_points, strBuffer);
	return points;
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

char[] GetName(client) {
	new String:name[16];
	GetClientName(client, name, 16)
	return name;
}

Beacon(name) {
	InsertServerCommand("sm_beacon %s", GetName(name));
}
