const int 	TEAM_T = 2,
			TEAM_CT = 3;

char[] GetName(client) {
	new String:name[MAX_NAME_LENGTH];
	GetClientName(client, name, MAX_NAME_LENGTH);
	return name;
}

String:plural(num) {
	new String:str[2] = "s";
	if (num == 1) {
		str[0] = 0;
	}
	return str;
}

String:Chat_GetPlayerColor(client) {
	decl String:buffer[5] = "";
	switch (GetClientTeam(client)) {
		case TEAM_T:
		{
			buffer = "\x09";
		}
		case TEAM_CT:
		{
			buffer = "\x0D";
		}
	}
	return buffer;
}

Client_Init(client) {
	if (Client_IsValid(client)) {
		if (GetClientCookieTime(client, cookie_points) < event_starttime) {
			SetClientCookie(client, cookie_points, "0");
		}
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
