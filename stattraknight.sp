#include <sourcemod>
#include <clientprefs>
#include <smlib>

new T_TARGET, CT_TARGET;
new bool:running = false;

new event_starttime;
new Handle:cookie_points;
new ArrayList:winners;
new topPoints;

public Plugin myinfo =
{
	name = "StatTrak Night",
	author = "Ben Whitley",
	description = "A plugin to automate StatTrak Night events",
	version = "0.9.4",
	url = "https://github.com/purplg/StatTrakNight"
};

#include "stattraknight/events.sp"
#include "stattraknight/util.sp"
#include "stattraknight/announcements.sp"
#include "stattraknight/menu.sp"

public void OnPluginStart() {
	winners = CreateArray(1, 1);

	RegConsoleCmd("sm_stattrak", Command_StatTrak, "sm_stattrak [0|1]");
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("cs_win_panel_match", Event_EndMatch);
	HookEvent("bot_takeover", Event_BotTakeover);
	cookie_points = RegClientCookie("stattrak_points", "The points each client has earned", CookieAccess_Protected);
}

public Action:Command_StatTrak(client, args) {
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	if (GetCmdArgs() > 0) {
		if (Client_IsValid(client) && !Client_HasAdminFlags(client, ADMFLAG_SLAY)) {
			Client_Reply(client, "[SM] %t", "No Access");
			return Plugin_Handled;
		}
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
		showScores(client);
	}
	return Plugin_Handled;
}

start() {
	event_starttime = GetTime();
	running = true;
	Client_PrintToChatAll(false, "[ST] \x04Starting StatTrak Night next round");
}

stop() {
	if (running) {
		reset_cookies();
		running = false;
		Client_PrintToChatAll(false, "[ST] \x04StatTrak Night has ended");
	}
}

reset_cookies() {
	new
		size = Client_GetCount(),
		players[size];
	Client_Get(players, CLIENTFILTER_INGAME);

	event_starttime = GetTime();

	for (new i; i < size; i++) {
		if (Client_IsValid(players[i])) {
			SetClientCookie(players[i], cookie_points, "0");
		}
	}
}

update_winners() {
	new	size = Client_GetCount(),
		players[size];
	Client_Get(players, CLIENTFILTER_INGAME);

	ClearArray(winners);
	topPoints = 0;
	for (new i; i < size; i++) {
		if (players[i] != 0) {
			new points = getPoints(players[i]);
			if (points == 0) continue;

			if (points > topPoints) {
				ClearArray(winners);
				PushArrayCell(winners, players[i]);
				topPoints = points;
			} else if (points == topPoints) {
				PushArrayCell(winners, players[i]);
			}
		}
	}
}
