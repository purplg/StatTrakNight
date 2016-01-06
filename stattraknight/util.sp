char prefix[] = "[ \x03StatTrakNight\x01 ]";

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

int Client_FindByUid(char[] uid) {
    int client = Client_FindBySteamId(uid);
    if (client == -1) {
	client = Client_FindByName(uid);
    }
    return client;
}

char[] Chat_GetPlayerColor(int client) {
    char buffer[5];
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

void reset_game() {
    scoreboard_players.Clear();
    scoreboard_points.Clear();
}

void PrintServer(const char[] msg, any:...) {
    char buffer[254];
    VFormat(buffer, sizeof(buffer), msg, 2);
    PrintToServer("%s %s", prefix, buffer);
}

void PrintClient(int client, const char[] msg, any:...) {
    char buffer[254];
    VFormat(buffer, sizeof(buffer), msg, 3);
    PrintToChat(client, "%s %s", prefix, buffer);
}

void PrintAll(const char[] msg, any:...) {
    char buffer[512];
    VFormat(buffer, sizeof(buffer), msg, 2);
    PrintToChatAll("%s %s", prefix, buffer);
}

void Reply(int client, const char[] msg, any:...) {
    char buffer[254];
    VFormat(buffer, sizeof(buffer), msg, 3);
    ReplyToCommand(client, "%s %s", prefix, buffer);
}
