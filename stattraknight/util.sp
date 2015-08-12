char[] GetName(client) {
	new String:name[MAX_NAME_LENGTH];
	GetClientName(client, name, MAX_NAME_LENGTH);
	return name;
}

String:plural_points(num) {
	new String:str[6] = "points";
	if (num == 1) {
		str[5] = 0;
	}
	return str;
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
