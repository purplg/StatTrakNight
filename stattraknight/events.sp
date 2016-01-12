public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
    Funcommands_Event_RoundStart();
    if (starting) {
	starting = false;
	running = true;
	stopping = false;
	Weapon_NewGroup();
    }
    if (stopping) {
	Game_FullStop();
    }
    if (starting && GameRules_GetProp("m_bWarmupPeriod")) {
	return;
    }
    if (running) {
	PrintAll("\x04This is a beta version of the StatTrakNight plugin. Expect bugs.");
	T_TARGET = BeaconRandom(2);
	CT_TARGET = BeaconRandom(3);

	Print_Leaders();
	PrintAll("%s%s\x01 and %s%s\x01 are the targets.",
	    Print_GetPlayerColor(CT_TARGET), Client_GetName(CT_TARGET),
	    Print_GetPlayerColor(T_TARGET) ,Client_GetName(T_TARGET));
	PrintAll("Kill them with \x04%ss\x01.", weapon_targetGroup);
    }
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) {
    if (starting) {
	starting = false;
	running = true;
	stopping = false;
	Game_Start(0, 5);
    } else if (stopping) {
	Game_FullStop();
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

		PrintAll("%s%s\x01 is the new target.", Print_GetPlayerColor(victim), Client_GetName(CT_TARGET));
		return;
	    }
	    char weapon[32];
	    GetEventString(event, "weapon", weapon, 32);
	    if (Weapons_IsTargetGroup(weapon)) {
		int points = Points_Add(attacker);
		PrintAll("%s%s\x01 was killed by %s%s\x01 \x04[%i point%s]", Print_GetPlayerColor(victim),
		    Client_GetName(victim), Print_GetPlayerColor(attacker), Client_GetName(attacker), points, Format_Plural(points));
		if (GetClientTeam(victim) == TEAM_CT)
		    CT_TARGET = -1;
		else if (GetClientTeam(victim) == TEAM_T)
		    T_TARGET = -1;
	    } else {
		PrintAll("%s%s\x01 was killed with the wrong weapon.", Print_GetPlayerColor(victim),
		    Client_GetName(victim));
	    }
	}
    }
}

public void Event_EndMatch(Event event, const char[] name, bool dontBroadcast) {
    if (running) {
	Game_FullStop();
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

