char prefix[] = "[ \x03StatTrakNight\x01 ]";

void Print_Leaders() {
    int numLeaders = Points_GetNumLeaders();

    if (numLeaders == 0) {
	PrintAll("No one has scored any points yet.");
    } else if (numLeaders == 1) {
	int points = scoreboard_points.Get(0);
	PrintAll("%s is leading with %i point%s",
	    Format_Tie(numLeaders),
	    points,
	    Format_Plural(points));
    } else {
	int points = scoreboard_points.Get(0);
	PrintAll("%s are leading with %i point%s",
	    Format_Tie(numLeaders),
	    points,
	    Format_Plural(points));
    }
}

void Print_Winners() {
    int numWinners = Points_GetNumLeaders();

    if (numWinners == 0) {
	PrintAll("No one won.");
    } else {
	int points = scoreboard_points.Get(0);
	PrintAll("%s won with %i point%s",
	    Format_Tie(numWinners),
	    points,
	    Format_Plural(points));
    }
}

char[] Print_GetPlayerColor(int client) {
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
    PrintToServer("%s %s", prefix, buffer);
}

void Reply(int client, const char[] msg, any:...) {
    char buffer[254];
    VFormat(buffer, sizeof(buffer), msg, 3);
    Client_Reply(client, "%s %s", prefix, buffer);
}
