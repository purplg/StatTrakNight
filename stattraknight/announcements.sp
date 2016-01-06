void print_leaders() {
    int numLeaders = get_num_leaders();

    if (numLeaders == 0) {
	PrintAll("No one has scored any points yet.");
    } else if (numLeaders == 1) {
	int points = scoreboard_points.Get(0);
	PrintAll("%s is leading with %i point%s",
	    format_tie(numLeaders),
	    points,
	    plural(points));
    } else {
	int points = scoreboard_points.Get(0);
	PrintAll("%s are leading with %i point%s",
	    format_tie(numLeaders),
	    points,
	    plural(points));
    }
}

void print_winners() {
    int numWinners = get_num_leaders();

    if (numWinners == 0) {
	PrintAll("No one won.");
    } else {
	int points = scoreboard_points.Get(0);
	PrintAll("%s won with %i point%s",
	    format_tie(numWinners),
	    points,
	    plural(points));
    }
}

int get_num_leaders() {
    // Check if any winners
    if (scoreboard_points.Length == 0) {
	return 0;
    }

    // Count number of winners
    int points = scoreboard_points.Get(0);
    int numLeaders = 1;
    while (numLeaders < scoreboard_points.Length) {
	if (scoreboard_points.Get(numLeaders) < points) {
	    break;
	}
	numLeaders++;
    }
    return numLeaders;
}

char[] format_tie(int numLeaders) {
    char str[255];
    char buffer[32];
    if (numLeaders == 1) {
	scoreboard_players.GetString(0, buffer, sizeof(buffer));
	int client = Client_FindByUid(buffer);

	Format(str, sizeof(str), "%s%s\x01",
	    Chat_GetPlayerColor(client), GetName(client));
    } else if (numLeaders == 2) {
	scoreboard_players.GetString(0, buffer, sizeof(buffer));
	int client1 = Client_FindByUid(buffer);
	scoreboard_players.GetString(1, buffer, sizeof(buffer));
	int client2 = Client_FindByUid(buffer);
	Format(str, sizeof(str), "%s%s\x01 and %s%s\x01",
	    Chat_GetPlayerColor(client1), GetName(client1),
	    Chat_GetPlayerColor(client2), GetName(client2)
	);
    } else {
	scoreboard_players.GetString(0, buffer, sizeof(buffer));
	int client1 = Client_FindByUid(buffer);
	scoreboard_players.GetString(1, buffer, sizeof(buffer));
	int client2 = Client_FindByUid(buffer);
	Format(str, sizeof(str), "%s%s\x01, %s%s\x01",
	    Chat_GetPlayerColor(client1), GetName(client1),
	    Chat_GetPlayerColor(client2), GetName(client2)
	);
	int client;
	for (int i = 2; i < scoreboard_players.Length-2; i++) {
	    scoreboard_players.GetString(i, buffer, sizeof(buffer));
	    client = Client_FindByUid(buffer);
	    Format(str, sizeof(str), "%s, %s%s\x01",
		str, Chat_GetPlayerColor(client), GetName(client));
	}
	scoreboard_players.GetString(scoreboard_players.Length-1, buffer, sizeof(buffer));
	client = Client_FindByUid(buffer);
	Format(str, sizeof(str), "%s, and %s%s\x01",
	    str, Chat_GetPlayerColor(client), GetName(client));
    }
    return str;
}
