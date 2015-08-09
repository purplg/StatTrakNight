public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
	if (started) {
		Client_PrintToChatAll(false, "[ST] \x04This is a pre-release version of the StatTrakNight plugin. Expect bugs.");
		T_TARGET = Client_GetRandom(CLIENTFILTER_TEAMONE | CLIENTFILTER_ALIVE);
		CT_TARGET = Client_GetRandom(CLIENTFILTER_TEAMTWO | CLIENTFILTER_ALIVE);
		Beacon(T_TARGET);
		Beacon(CT_TARGET);
		calc_winners();
		Client_PrintToChatAll(false, "[ST] \x0D%s\x01 and \x09%s\x01 are the targets.", GetName(CT_TARGET), GetName(T_TARGET));
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
			Client_PrintToChatAll(false, "[ST] \x09%s was killed by %s! (%i %s)",
				GetName(victim), GetName(attacker), points, plural_points(points));
		} else if (victim == T_TARGET) {
			new points = addPoint(attacker);
			Client_PrintToChatAll(false, "[ST] \x0D%s was killed by %s! (%i %s)",
				GetName(victim), GetName(attacker), points, plural_points(points));
		}
	}
}

public void Event_EndMatch(Event event, const char[] name, bool dontBroadcast) {
	if (started) {
		calc_winners(true);
		reset_cookies();
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
	reset_cookies();
}
