public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
    Funcommands_Event_RoundStart();
    if (starting) {
	starting = false;
	running = true;
	stopping = false;
	event_starttime = GetTime();
	Weapon_NewGroup();
    }
    if (stopping) {
	complete_stop();
    }
    if (starting && GameRules_GetProp("m_bWarmupPeriod")) {
	return;
    }
    if (running) {
	PrintAll("\x04This is a beta version of the StatTrakNight plugin. Expect bugs.");
	T_TARGET = BeaconRandom(2);
	CT_TARGET = BeaconRandom(3);

	update_winners();
	print_leaders();
	PrintAll("\x0D%s\x01 and \x09%s\x01 are the targets.", GetName(CT_TARGET), GetName(T_TARGET));
	PrintAll("Kill them with \x04%ss\x01.", weapon_targetGroup);
    }
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) {
    if (starting) {
	starting = false;
	running = true;
	stopping = false;
	event_starttime = GetTime();

	PrintAll("\x04Starting StatTrak Event in 5 seconds...");
	InsertServerCommand("mp_restartgame 5");
    } else if (stopping) {
	complete_stop();
    }
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
    if (running) {
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if (!Client_IsValid(attacker)) return;

	if (victim == CT_TARGET || victim == T_TARGET) {
	    if (victim == attacker) {
		if (GetClientTeam(victim) == TEAM_CT)
		    CT_TARGET = BeaconRandom(TEAM_CT);
		else if (GetClientTeam(victim) == TEAM_T)
		    T_TARGET = BeaconRandom(TEAM_T);

		PrintAll("%s%s\x01 is the new target.", Chat_GetPlayerColor(victim), GetName(CT_TARGET));
		return;
	    }
	    char weapon[32];
	    GetEventString(event, "weapon", weapon, 32);
	    if (Weapons_IsTargetGroup(weapon)) {
		int points = addPoint(attacker);
		PrintAll("%s%s\x01 was killed by %s%s\x01 \x04[%i point%s]", Chat_GetPlayerColor(victim),
		    GetName(victim), Chat_GetPlayerColor(attacker), GetName(attacker), points, plural(points));
		if (GetClientTeam(victim) == TEAM_CT)
		    CT_TARGET = -1;
		else if (GetClientTeam(victim) == TEAM_T)
		    T_TARGET = -1;
	    } else {
		PrintAll("%s%s\x01 was killed with the wrong weapon.", Chat_GetPlayerColor(victim),
		    GetName(victim));
	    }
	}
    }
}

public void Event_EndMatch(Event event, const char[] name, bool dontBroadcast) {
    if (running) {
	complete_stop();
    }
}

public void Event_BotTakeover(Event event, const char[] name, bool dontBroadcast) {
    int bot = GetClientOfUserId(GetEventInt(event, "botid"));

    if (bot == T_TARGET) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	T_TARGET = client;
	PerformBeacon(T_TARGET);
    } else if(bot == CT_TARGET) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	CT_TARGET = client;
	PerformBeacon(CT_TARGET);
    }
}

/**
* When a client joins, this is called when that client receives it's stored cookies from the server.
* This function will check to see if the points earned are for the current event, and if not erase them.
*/
public void OnClientCookiesCached(int client) {
    Client_Init(client);
}

public void OnMapEnd() {
    Funcommands_OnMapEnd();
    complete_stop();
}

public void OnMapStart() {
    Funcommands_OnMapStart();
}
