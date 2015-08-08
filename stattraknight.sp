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
	version = "0.9.1",
	url = "https://github.com/purplg/StatTrakNight"
};

#include "stattraknight/events.sp"
#include "stattraknight/util.sp"
#include "stattraknight/announcements.sp"

public void OnPluginStart() {
	RegConsoleCmd("sm_stattrak", Command_StatTrak);
	HookEvent("cs_match_end_restart", Event_GameStart);
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
	if (!started || GetClientCookieTime(client, cookie_points) < event_starttime) {
		SetClientCookie(client, cookie_points, "0");
	}
}

public Action:Command_StatTrak(client, args) {
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	if (arg1[0] != 0) {
		switch (StringToInt(arg1)) {
			case 1: {
				stop();
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
	Client_PrintToChatAll(false, "[ST] \x04Starting StatTrak Night next round");
}

stop() {
	if (started) {
		new players[MaxClients];
		Client_Get(players, CLIENTFILTER_INGAME);
		for (new i; i < MaxClients; i++) {
			if (Client_IsValid(players[i]))
				SetClientCookie(players[i], cookie_points, "0");
		}
		started = false;
		Client_PrintToChatAll(false, "[ST] \x04StatTrak Night has ended");
	}
}

calc_winners(bool:end_of_game=false) {
	new t_size = Team_GetClientCount(2);
	new ct_size = Team_GetClientCount(3);
	new size = t_size;
	if (ct_size > t_size) size = ct_size;

	new t_players[t_size];
	new ct_players[ct_size];
	Client_Get(t_players, CLIENTFILTER_TEAMONE);
	Client_Get(ct_players, CLIENTFILTER_TEAMTWO);

	new t_winners[t_size];
	new t_num_winners;
	new t_points;
	new ct_winners[ct_size];
	new ct_num_winners;
	new ct_points;
	new points;

	for (new i = 0; i < size; i++) {
		if (t_players[i] != 0) {
			points = getPoints(t_players[i]);
			if (points == 0) continue;
			if (points > t_points) {
				t_winners[0] = t_players[i];
				t_points = points;
				t_num_winners = 1;
			} else if (points == t_points) {
				t_winners[t_num_winners++] = t_players[i];
			}
		}
		if (ct_players[i] != 0) {
			points = getPoints(ct_players[i]);
			if (points == 0) continue;
			if (points > ct_points) {
				ct_winners[0] = ct_players[i];
				ct_points = points;
				ct_num_winners = 1;
			} else if (points == ct_points) {
				ct_winners[ct_num_winners++] = ct_players[i];
			}
		}
	}
	if (end_of_game)
		print_winners(t_winners, t_num_winners, t_points, ct_winners, ct_num_winners, ct_points);
	else
		print_leaders(t_winners, t_num_winners, t_points, ct_winners, ct_num_winners, ct_points);
}
