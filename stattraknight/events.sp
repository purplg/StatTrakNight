public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs) {
	if (StrContains(sArgs, "!st ", false) == 0) {
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
	Funcommands_Event_RoundStart();
	if (starting) {
		Game_Reset();
		running = true;
		Weapon_NewGroup();
	}
	
	if (stopping) {
		Game_FullStop();
	}

	if (starting && GameRules_GetProp("m_bWarmupPeriod")) {
		return;
	}

	if (running) {
		Game_NewRound();
	}
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	if (running) {
		int victim = GetClientOfUserId(GetEventInt(event, "userid"));
		int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
		if (!Client_IsValid(attacker))
			return;

		if (victim == CT_TARGET || victim == T_TARGET) {

			// Not a suicide
			if (victim != attacker) {

				// Is player (not bot), then test if it's correct weapon
				if (!IsFakeClient(attacker)) {
					char weapon[32];
					GetEventString(event, "weapon", weapon, 32);
					if (Weapons_IsTargetGroup(weapon)) {
						TargetKilled(attacker, victim);
					} else {
						Print_WrongWeapon(victim);
					}
				
				// Bots can kill with any weapon
				} else {
					TargetKilled(attacker, victim);
				}
			} else {
				// Pick a new target if player suicides
				if (GetClientTeam(victim) == TEAM_CT) {
					CT_TARGET = BeaconRandom(TEAM_CT);
					Print_NewTarget(CT_TARGET);
				}
				else if (GetClientTeam(victim) == TEAM_T) {
					T_TARGET = BeaconRandom(TEAM_T);
					Print_NewTarget(T_TARGET);
				}
			}
		}
	}
}

void TargetKilled(int attacker, int victim) {
	int points = Points_Add(attacker);
	Print_TargetKilled(attacker, victim, points);

	if (GetClientTeam(victim) == TEAM_CT)
		CT_TARGET = -1;
	else if (GetClientTeam(victim) == TEAM_T)
		T_TARGET = -1;
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

