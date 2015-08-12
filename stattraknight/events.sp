public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
	if (running) {
		Client_PrintToChatAll(false, "[ST] \x04This is a pre-release version of the StatTrakNight plugin. Expect bugs.");
		T_TARGET = Client_GetRandom(CLIENTFILTER_TEAMONE | CLIENTFILTER_ALIVE);
		CT_TARGET = Client_GetRandom(CLIENTFILTER_TEAMTWO | CLIENTFILTER_ALIVE);
		PerformBeacon(T_TARGET);
		PerformBeacon(CT_TARGET);

		update_winners();
		print_leaders();
		Client_PrintToChatAll(false, "[ST] \x0D%s\x01 and \x09%s\x01 are the targets.", GetName(CT_TARGET), GetName(T_TARGET));
	}
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	if (running) {
		int victim = GetClientOfUserId(GetEventInt(event, "userid"));
		int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

		if (victim == attacker) return;
		if (!Client_IsValid(attacker)) return;

		if (victim == CT_TARGET) {
			new points = addPoint(attacker);
			Client_PrintToChatAll(false, "[ST] \x09%s was killed by %s! (%i %s)",
				GetName(victim), GetName(attacker), points, plural_points(points));
			CT_TARGET = -1;
		} else if (victim == T_TARGET) {
			new points = addPoint(attacker);
			Client_PrintToChatAll(false, "[ST] \x0D%s was killed by %s! (%i %s)",
				GetName(victim), GetName(attacker), points, plural_points(points));
			T_TARGET = -1;
		}
	}
}

public void Event_EndMatch(Event event, const char[] name, bool dontBroadcast) {
	if (running) {
		update_winners();
		print_winners();
		reset_cookies();
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
public void OnClientCookiesCached(client) {
	Client_Init(client);
}


public OnMapEnd() {
	Funcommands_OnMapEnd();
	reset_cookies();
}
