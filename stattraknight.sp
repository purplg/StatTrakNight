#include <sourcemod>
#include <clientprefs>
#include <smlib>
#include <sdktools>

int T_TARGET, CT_TARGET;
bool starting, stopping, running;

int event_starttime;
Handle cookie_points;

public Plugin myinfo =
{
    name = "StatTrak Night",
    author = "Ben Whitley",
    description = "A plugin to automate StatTrak Night events",
    version = "0.9.6",
    url = "https://github.com/purplg/StatTrakNight"
};

#include "stattraknight/beacon/funcommands.sp"
#include "stattraknight/weapons.sp"
#include "stattraknight/points.sp"
#include "stattraknight/sounds.sp"
#include "stattraknight/util.sp"
#include "stattraknight/events.sp"
#include "stattraknight/announcements.sp"
#include "stattraknight/menu.sp"

public void OnPluginStart() {
    Funcommands_OnPluginStart();
    winners = CreateArray(1, 1);

    Sounds_Load();
    Weapons_Load();

    RegConsoleCmd("sm_st_points", Command_stattrak, "sm_st_points");
    RegAdminCmd("sm_st_start", Command_stattrak_start, ADMFLAG_SLAY, "sm_st_start  [time]");
    RegAdminCmd("sm_st_stop", Command_stattrak_stop, ADMFLAG_SLAY, "sm_st_stop [time]");
    HookEvent("round_start", Event_RoundStart);
    HookEvent("round_end", Event_RoundEnd);
    HookEvent("player_death", Event_PlayerDeath);
    HookEvent("cs_win_panel_match", Event_EndMatch);
    HookEvent("bot_takeover", Event_BotTakeover);
    cookie_points = RegClientCookie("stattrak_points", "The points each client has earned", CookieAccess_Protected);
}

public Action Command_stattrak(int client, int args) {
    int points = getPoints(client);
    PrintClient(client, "\x04You have %i point%s.", points, plural(points));
    //		showScores(client);
    return Plugin_Handled;
}

public Action Command_stattrak_start(int client, int args) {
    char arg_time[32];
    GetCmdArg(1, arg_time, sizeof(arg_time));
    start(client, StringToInt(arg_time));
    return Plugin_Handled;
}

public Action Command_stattrak_stop(int client, int args) {
    char arg_time[32];
    GetCmdArg(1, arg_time, sizeof(arg_time));
    stop(client, StringToInt(arg_time));
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
void start(int client, int time=0) {
    if (starting) {
	if (time > 0) {
	    PrintAll("\x04Starting StatTrak event in %i second%s.", time, plural(time));
	    InsertServerCommand("mp_restartgame %i", time);
	    InsertServerCommand("mp_warmup_end");
	} else {
	    Client_Reply(client, "\x04StatTrak event already starting next round.");
	}
    } else if (stopping) {
	stopping = false;
	PrintAll("\x04StatTrak Night set to continue.");
    } else if (running) {
	Client_Reply(client, "\x04StatTrak event already running.");
    } else {
	starting = true;
	if (time > 0) {
	    PrintAll("\x04Starting StatTrak event in %i second%s.", time, plural(time));
	    InsertServerCommand("mp_restartgame %i", time);
	    InsertServerCommand("mp_warmup_end");
	} else {
	    Reply(client, "\x04Starting StatTrak event next round.");
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
void stop(client=0, time=0) {
    if (stopping) {
	if (time > 0) {
	    PrintAll("\x04Stopping StatTrak event in %i seconds.", time);
	    InsertServerCommand("mp_restartgame %i", time);
	    InsertServerCommand("mp_warmup_end");
	} else {
	    Reply(client, "\x04StatTrak event already starting next round.");
	}
    } else if (starting) {
	starting = false;
	PrintAll("\x04StatTrak Event cancelled for next round.");
    } else if (running) {
	stopping = true;
	if (time > 0) {
	    PrintAll("\x04Stopping StatTrak event in %i seconds.", time);
	    InsertServerCommand("mp_restartgame %i", time);
	    InsertServerCommand("mp_warmup_end");
	} else {
	    PrintAll("\x04StatTrak Night will end next round.");
	}
    } else {
	Reply(client, "\x04There isn't a StatTrak Event running.");
    }
}

void complete_stop() {
    running = false;
    stopping = false;
    starting = false;
    update_winners();
    print_winners();
    reset_cookies();
}
