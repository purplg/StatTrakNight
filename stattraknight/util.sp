const int TEAM_T = 2, TEAM_CT = 3;

char[] GetName(int client) {
    char name[MAX_NAME_LENGTH];
    GetClientName(client, name, MAX_NAME_LENGTH);
    return name;
}

char[] plural(int num) {
    char str[2] = "s";
    if (num == 1) {
	str[0] = 0;
    }
    return str;
}

char[] Chat_GetPlayerColor(int client) {
    char buffer[5] = "";
    switch (GetClientTeam(client)) {
	case TEAM_T: {
	    buffer = "\x09";
	}
	case TEAM_CT: {
	    buffer = "\x0D";
	}
    }
    return buffer;
}

void Client_Init(int client) {
    if (Client_IsValid(client)) {
	if (GetClientCookieTime(client, cookie_points) < event_starttime) {
	    SetClientCookie(client, cookie_points, "0");
	}
    }
}

void reset_cookies() {
    int size = Client_GetCount();
    int[] clients = new int[size];
    Client_Get(clients, CLIENTFILTER_INGAME);

    event_starttime = GetTime();

    for (int i; i < size; i++) {
	if (Client_IsValid(clients[i])) {
	    SetClientCookie(clients[i], cookie_points, "0");
	}
    }
}
