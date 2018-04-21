char[] Format_Plural(int num) {
	char str[2] = "s";
	if (num == 1) {
	str[0] = 0;
	}
	return str;
}

char[] Format_Tie(int numLeaders) {
	char str[255];
	char buffer[32];
	if (numLeaders == 1) {
	scoreboard_players.GetString(0, buffer, sizeof(buffer));
	int client = Client_FindByUid(buffer);

	Format(str, sizeof(str), "%s%s\x01",
		Format_GetPlayerColor(client), Client_GetName(client));
	} else if (numLeaders == 2) {
	scoreboard_players.GetString(0, buffer, sizeof(buffer));
	int client1 = Client_FindByUid(buffer);
	scoreboard_players.GetString(1, buffer, sizeof(buffer));
	int client2 = Client_FindByUid(buffer);
	Format(str, sizeof(str), "%s%s\x01 and %s%s\x01",
		Format_GetPlayerColor(client1), Client_GetName(client1),
		Format_GetPlayerColor(client2), Client_GetName(client2)
	);
	} else {
	scoreboard_players.GetString(0, buffer, sizeof(buffer));
	int client1 = Client_FindByUid(buffer);
	scoreboard_players.GetString(1, buffer, sizeof(buffer));
	int client2 = Client_FindByUid(buffer);
	Format(str, sizeof(str), "%s%s\x01, %s%s\x01",
		Format_GetPlayerColor(client1), Client_GetName(client1),
		Format_GetPlayerColor(client2), Client_GetName(client2)
	);
	int client;
	for (int i = 2; i < numLeaders-1; i++) {
		scoreboard_players.GetString(i, buffer, sizeof(buffer));
		client = Client_FindByUid(buffer);
		Format(str, sizeof(str), "%s, %s%s\x01",
		str, Format_GetPlayerColor(client), Client_GetName(client));
	}
	scoreboard_players.GetString(numLeaders-1, buffer, sizeof(buffer));
	client = Client_FindByUid(buffer);
	Format(str, sizeof(str), "%s, and %s%s\x01",
		str, Format_GetPlayerColor(client), Client_GetName(client));
	}
	return str;
}
