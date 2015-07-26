#include <sourcemod>
#include <clientprefs>
#include <smlib>

new T_TARGET, CT_TARGET;
new bool:started = false;

new event_starttime;
new Handle:cookie_points;

public Plugin myinfo =
{
	name = "StatTrak Night",
	author = "Ben Whitley",
	description = "A plugin to automate StatTrak Night events",
	version = "0.1",
	url = "https://github.com/purplg/StatTrakNight"
};

public void OnPluginStart() {
	RegConsoleCmd("sm_stattrak", Command_StatTrak);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("cs_win_panel_match", Event_WinPanelMatch);
	cookie_points = RegClientCookie("stattrak_points", "The points each client has earned", CookieAccess_Protected);
}

/**
 * When a client joins, this is called when that client receives it's stored cookies from the server.
 * This function will check to see if the points earned are for the current event, and if not erase them.
 */
public void OnClientCookiesCached(client) {
	if (started) {
		decl String:strBuffer[3];
		GetClientCookie(client, cookie_points, strBuffer, 3);
		if (GetClientCookieTime(client, cookie_points) < event_starttime) {
			SetClientCookie(client, cookie_points, "0");
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

printLeaders() {
	new t_size = Team_GetClientCount(2);
	new ct_size = Team_GetClientCount(3);
	new size = t_size;
	if (ct_size > t_size) size = ct_size;

	new t_players[t_size];
	new ct_players[ct_size];
	Client_Get(t_players, CLIENTFILTER_TEAMONE);
	Client_Get(ct_players, CLIENTFILTER_TEAMTWO);

	new t_winners[t_size];
	new t_index;
	new t_points;
	new ct_winners[t_size];
	new ct_index;
	new ct_points;
	new points;

	for (new i = 0; i < size; i++) {
		if (t_players[i] != 0) {
			points = getPoints(t_players[i]);
			if (points == 0) continue;
			if (points > t_points) {
				t_winners[0] = t_players[i];
				t_points = points;
				t_index = 1;
			} else if (points == t_points) {
				t_winners[t_index++] = t_players[i];
			}
		}
		if (ct_players[i] != 0) {
			points = getPoints(ct_players[i]);
			if (points == 0) continue;
			if (points > ct_points) {
				ct_winners[0] = ct_players[i];
				ct_points = points;
				ct_index = 1;
			} else if (points == ct_points) {
				ct_winners[ct_index++] = ct_players[i];
			}
		}
	}
	if (t_points > 0) {
		if (t_index == 1) {
			if (t_points == 1)
				Client_PrintToChatAll(false, "{R}%s is leading the Ts with %i point!{N}", GetName(t_winners[0]), t_points);
			else
				Client_PrintToChatAll(false, "{R}%s is leading the Ts with %i points!{N}", GetName(t_winners[0]), t_points);
		} else if (t_index > 1) {
			Client_PrintToChatAll(false, "{R}Tie between %s{N}", format_tie_message(t_winners, t_index, t_points));
		}
	} else {
		Client_PrintToChatAll(false, "{R}No one on Terrorists has scored any points yet.{N}");
	}
	if (ct_points > 0) {
		if (ct_index == 1) {
			if (ct_points == 1)
				Client_PrintToChatAll(false, "{B}%s is leading the CTs with %i point!{N}", GetName(ct_winners[0]), ct_points);
			else
				Client_PrintToChatAll(false, "{B}%s is leading the CTs with %i points!{N}", GetName(ct_winners[0]), ct_points);
		} else if (ct_index > 1) {
			Client_PrintToChatAll(false, "{B}Tie between %s{N}", format_tie_message(ct_winners, ct_index, ct_points));
		}
	} else {
		Client_PrintToChatAll(false, "{B}No one on CT has scored any points yet.{N}");
	}
}

start() {
	event_starttime = GetTime();
	started = true;
	Client_PrintToChatAll(false, "Starting StatTrak Night next round");
}

stop() {
	started = false;
	Client_PrintToChatAll(false, "StatTrak Night has ended");
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
	if (started) {
		T_TARGET = Client_GetRandom(CLIENTFILTER_TEAMONE | CLIENTFILTER_ALIVE);
		CT_TARGET = Client_GetRandom(CLIENTFILTER_TEAMTWO | CLIENTFILTER_ALIVE);
		Beacon(T_TARGET);
		Beacon(CT_TARGET);
		printLeaders();
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
			if (points == 1)
				Client_PrintToChatAll(false, "{R}%s was killed by %s! (%i point){N}",
					GetName(victim), GetName(attacker), points);
			else
				Client_PrintToChatAll(false, "{R}%s was killed by %s! (%i points){N}",
					GetName(victim), GetName(attacker), points);
		} else if (victim == T_TARGET) {
			new points = addPoint(attacker);
			if (points == 1)
				Client_PrintToChatAll(false, "{B}%s was killed by %s! (%i point){N}",
					GetName(victim), GetName(attacker), points);
			else
				Client_PrintToChatAll(false, "{B}%s was killed by %s! (%i points){N}",
					GetName(victim), GetName(attacker), points);
		}
	}
}

public void Event_WinPanelMatch(Event event, const char[] name, bool dontBroadcast) {
	if (started) {
		stop();
	}
}

int getPoints(client) {
		decl String:strBuffer[3];
		GetClientCookie(client, cookie_points, strBuffer, 3);
		return StringToInt(strBuffer);
}

int addPoint(client) {
	decl String:strBuffer[3];
	GetClientCookie(client, cookie_points, strBuffer, 3);
	new points = StringToInt(strBuffer) + 1;
	IntToString(points, strBuffer, 3);
	SetClientCookie(client, cookie_points, strBuffer);
	return points;
}

char[] GetName(client) {
	new String:name[16];
	GetClientName(client, name, 16)
	return name;
}

String:format_tie_message(winners[], size, points) {
	decl String:str[255];
	if (size == 1) {
		Format(str, sizeof(str), "%s with %i points", GetName(winners[0]), points);
	} else if (size == 2) {
		Format(str, sizeof(str), "%s and %s with %i points", GetName(winners[0]), GetName(winners[1]), points);
	} else {
		Format(str, sizeof(str), "%s, %s", GetName(winners[0]), GetName(winners[1]));
		for (new i = 2; i < size-1; i++) {
			Format(str, sizeof(str), "%s, %s", str, GetName(winners[i]));
		}
		Format(str, sizeof(str), "%s, and %s with %i points", str, GetName(winners[size-1]), points);
	}
	return str;
}

Beacon(name) {
	InsertServerCommand("sm_beacon %s", GetName(name));
}
