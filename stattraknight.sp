#include <sourcemod>
#include <clientprefs>
#include <smlib>

new T_TARGET, CT_TARGET;
new bool:starting = false,
	bool:stopping = false,
	bool:running = false;

new event_starttime;
new Handle:cookie_points;

public Plugin myinfo =
{
	name = "StatTrak Night",
	author = "Ben Whitley",
	description = "A plugin to automate StatTrak Night events",
	version = "0.9.4",
	url = "https://github.com/purplg/StatTrakNight"
};

#include "stattraknight/beacon/funcommands.sp"
#include "stattraknight/weapons.sp"
#include "stattraknight/points.sp"
#include "stattraknight/sounds.sp"
#include "stattraknight/events.sp"
#include "stattraknight/util.sp"
#include "stattraknight/announcements.sp"
#include "stattraknight/menu.sp"

public void OnPluginStart() {
	Funcommands_OnPluginStart();
	winners = CreateArray(1, 1);

	Sounds_Load();
	Weapons_Load();

	RegConsoleCmd("sm_stattrak", Command_StatTrak, "sm_stattrak [0/1/start/stop] [time]");
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("cs_win_panel_match", Event_EndMatch);
	HookEvent("bot_takeover", Event_BotTakeover);
	cookie_points = RegClientCookie("stattrak_points", "The points each client has earned", CookieAccess_Protected);
}

public Action:Command_StatTrak(client, args) {
	decl
		String:arg1[32],
		String:arg2[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	if (GetCmdArgs() > 0) {
		if (Client_IsValid(client) && !Client_HasAdminFlags(client, ADMFLAG_SLAY)) {
			Client_Reply(client, "[SM] %t", "No Access");
			return Plugin_Handled;
		}
		new time = 0;
		if (strlen(arg2) > 0) {
			time = StringToInt(arg2);
		}
		if (strcmp("start", arg1, false) == 0
		|| 	strcmp("1", arg1, false) == 0) {
			start(client, time);
		} else if (strcmp("stop", arg1, false) == 0
		||	strcmp("0", arg1, false) == 0) {
			stop(client, time);
		} else {
			Client_Reply(client, "[ST] Usage: sm_stattrak [0/1/start/stop] [time]");
		}
	} else {
//		showScores(client);
		new points = getPoints(client);
		Client_PrintToChat(client, false, "[ST] \x04You have %i point%s.", points, plural(points));
	}
	return Plugin_Handled;
}

/**
 * Set a StatTrak Event to start next round
 *
 * @param client	The client that called the event to start
 * @param time		The amount of time to wait to restart game to start event.
 					0 = Next round
 * @noreturn
 */
start(client, time=0) {
	if (starting) {
		if (time > 0) {
			Client_PrintToChatAll(false, "[ST] \x04Starting StatTrak event in %i second%s.", time, plural(time));
			InsertServerCommand("mp_restartgame %i", time);
		} else {
			Client_Reply(client, "[ST] \x04StatTrak event already starting next round.");
		}
	} else if (stopping) {
		stopping = false;
		Client_PrintToChatAll(false, "[ST] \x04StatTrak Night set to continue.");
	} else if (running) {
			Client_Reply(client, "[ST] \x04StatTrak event already running.");
	} else {
		starting = true;
		if (time > 0) {
			Client_PrintToChatAll(false, "[ST] \x04Starting StatTrak event in %i second%s.", time, plural(time));
			InsertServerCommand("mp_restartgame %i", time);
		} else {
			Client_Reply(client, "[ST] \x04Starting StatTrak event next round.");
		}
	}
}

/**
 * Stop a StatTrak Event next round
 *
 * @param client	The client that called the event to stop
 * @param time		The amount of time to wait to restart game to stop event.
 					0 = Next round
 * @noreturn
 */
stop(client, time=0) {
	if (stopping) {
		if (time > 0) {
			Client_PrintToChatAll(false, "[ST] \x04Stopping StatTrak event in %i seconds.", time);
			InsertServerCommand("mp_restartgame %i", time);
		} else {
			Client_Reply(client, "[ST] \x04StatTrak event already starting next round.");
		}
	} else if (starting) {
		starting = false;
		Client_PrintToChatAll(false, "[ST] \x04StatTrak Event cancelled for next round.");
	} else if (running) {
		stopping = true;
		if (time > 0) {
			Client_PrintToChatAll(false, "[ST] \x04Stopping StatTrak event in %i seconds.", time);
			InsertServerCommand("mp_restartgame %i", time);
		} else {
			Client_PrintToChatAll(false, "[ST] \x04StatTrak Night will end next round.");
		}
	} else {
		Client_Reply(client, "[ST] \x04There isn't a StatTrak Event running.");
	}
}

complete_stop() {
	running = false;
	stopping = false;
	starting = false;
	update_winners();
	print_winners();
	reset_cookies();
	Client_PrintToChatAll(false, "[ST] \x04StatTrak Night has ended.");
}
